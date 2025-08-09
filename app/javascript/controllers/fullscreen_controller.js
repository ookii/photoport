import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "image", "prevButton", "nextButton"]

  connect() {
    this.currentIndex = 0
    this.totalCount = 0
    this.gallerySlug = ""
    
    // Listen for escape key to close fullscreen
    this.boundKeyHandler = this.handleKeyPress.bind(this)
    document.addEventListener('keydown', this.boundKeyHandler)
  }

  disconnect() {
    document.removeEventListener('keydown', this.boundKeyHandler)
  }

  open(event) {
    // Get data from the clicked image
    this.currentIndex = parseInt(event.currentTarget.dataset.fullscreenCurrentIndex)
    this.totalCount = parseInt(event.currentTarget.dataset.fullscreenTotalCount)
    this.gallerySlug = event.currentTarget.dataset.fullscreenGallerySlug
    const imageUrl = event.currentTarget.dataset.fullscreenImageUrl
    
    // Set the fullscreen image
    this.imageTarget.src = imageUrl
    this.imageTarget.alt = `Image ${this.currentIndex + 1} of ${this.totalCount}`
    
    // Update navigation buttons
    this.updateNavigationButtons()
    
    // Show the overlay
    this.overlayTarget.classList.add('active')
    
    // Prevent body scrolling
    document.body.style.overflow = 'hidden'
  }

  close() {
    this.overlayTarget.classList.remove('active')
    document.body.style.overflow = ''
  }

  prev() {
    if (this.currentIndex > 0) {
      this.currentIndex--
    } else {
      // Wraparound to last image
      this.currentIndex = this.totalCount - 1
    }
    this.loadCurrentImage()
  }

  next() {
    if (this.currentIndex < this.totalCount - 1) {
      this.currentIndex++
    } else {
      // Wraparound to first image
      this.currentIndex = 0
    }
    this.loadCurrentImage()
  }

  async loadCurrentImage() {
    try {
      let response;
      
      // Handle different URL patterns for home vs gallery pages
      if (this.gallerySlug === 'home') {
        response = await fetch(`/home/${this.currentIndex}.json`)
      } else {
        response = await fetch(`/${this.gallerySlug}/${this.currentIndex}.json`)
      }
      
      const data = await response.json()
      
      // Update the fullscreen image
      this.imageTarget.src = data.image_url
      this.imageTarget.alt = `Image ${this.currentIndex + 1} of ${this.totalCount}`
      
      // Update navigation buttons
      this.updateNavigationButtons()
    } catch (error) {
      console.error('Error loading image:', error)
    }
  }

  updateNavigationButtons() {
    // Show/hide navigation buttons based on gallery size
    if (this.totalCount > 1) {
      this.prevButtonTarget.style.display = 'flex'
      this.nextButtonTarget.style.display = 'flex'
    } else {
      this.prevButtonTarget.style.display = 'none'
      this.nextButtonTarget.style.display = 'none'
    }
  }

  handleKeyPress(event) {
    if (!this.overlayTarget.classList.contains('active')) return
    
    switch (event.key) {
      case 'Escape':
        this.close()
        break
      case 'ArrowLeft':
        this.prev()
        break
      case 'ArrowRight':
        this.next()
        break
    }
  }
}