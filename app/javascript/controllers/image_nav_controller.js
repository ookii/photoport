import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    prevPath: String, 
    nextPath: String 
  }
  
  static targets = ["image", "prevButton", "nextButton", "loading"]

  connect() {
    this.boundKeyHandler = this.handleKeyPress.bind(this)
    document.addEventListener('keydown', this.boundKeyHandler)
    
    // Add pointer event listeners for swipe support
    this.boundPointerDown = this.handlePointerDown.bind(this)
    this.boundPointerMove = this.handlePointerMove.bind(this)
    this.boundPointerUp = this.handlePointerUp.bind(this)
    
    this.element.addEventListener('pointerdown', this.boundPointerDown)
    this.element.addEventListener('pointermove', this.boundPointerMove)
    this.element.addEventListener('pointerup', this.boundPointerUp)
    
    this.startX = 0
    this.currentX = 0
    this.isPointerDown = false
    this.minSwipeDistance = 50
  }

  disconnect() {
    if (this.boundKeyHandler) {
      document.removeEventListener('keydown', this.boundKeyHandler)
    }
    
    if (this.boundPointerDown) {
      this.element.removeEventListener('pointerdown', this.boundPointerDown)
      this.element.removeEventListener('pointermove', this.boundPointerMove)
      this.element.removeEventListener('pointerup', this.boundPointerUp)
    }
  }

  handleKeyPress(event) {
    switch(event.key) {
      case 'ArrowLeft':
      case 'h':
        event.preventDefault()
        this.goToPrev()
        break
      case 'ArrowRight':
      case 'l':
        event.preventDefault()
        this.goToNext()
        break
      case 'Escape':
        event.preventDefault()
        window.location.href = '/'
        break
    }
  }

  handlePointerDown(event) {
    // Only handle primary pointer (touch/left mouse button)
    if (event.isPrimary) {
      this.isPointerDown = true
      this.startX = event.clientX
      this.currentX = event.clientX
      this.element.setPointerCapture(event.pointerId)
    }
  }

  handlePointerMove(event) {
    if (!this.isPointerDown || !event.isPrimary) return
    
    this.currentX = event.clientX
    const deltaX = this.currentX - this.startX
    
    // Optional: Add visual feedback during swipe
    if (Math.abs(deltaX) > 10) {
      const opacity = Math.min(Math.abs(deltaX) / 100, 0.3)
      if (deltaX > 0 && this.prevPathValue) {
        this.element.style.backgroundColor = `rgba(59, 130, 246, ${opacity})`
      } else if (deltaX < 0 && this.nextPathValue) {
        this.element.style.backgroundColor = `rgba(59, 130, 246, ${opacity})`
      }
    }
  }

  handlePointerUp(event) {
    if (!this.isPointerDown || !event.isPrimary) return
    
    this.isPointerDown = false
    this.element.releasePointerCapture(event.pointerId)
    
    // Reset visual feedback
    this.element.style.backgroundColor = ''
    
    const deltaX = this.currentX - this.startX
    const absDeltaX = Math.abs(deltaX)
    
    if (absDeltaX > this.minSwipeDistance) {
      if (deltaX > 0) {
        // Swipe right (show previous)
        this.goToPrev()
      } else {
        // Swipe left (show next)
        this.goToNext()
      }
    }
  }

  goToPrev() {
    if (this.prevPathValue) {
      this.navigateTo(this.prevPathValue)
    }
  }

  goToNext() {
    if (this.nextPathValue) {
      this.navigateTo(this.nextPathValue)
    }
  }

  navigateTo(path) {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
    }
    
    // Use Turbo if available, otherwise fallback to regular navigation
    if (window.Turbo) {
      window.Turbo.visit(path)
    } else {
      window.location.href = path
    }
  }

  // Handle image load events
  imageLoaded() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('hidden')
    }
  }

  imageError() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('hidden')
    }
    console.error('Failed to load image')
  }
}