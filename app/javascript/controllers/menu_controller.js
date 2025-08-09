import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mobileButton", 
    "mobileMenu", 
    "submenu", 
    "submenuButton",
    "mobileSubmenu",
    "mobileSubmenuButton"
  ]

  connect() {
    this.boundClickOutside = this.handleClickOutside.bind(this)
    this.boundEscapeKey = this.handleEscapeKey.bind(this)
    
    document.addEventListener('click', this.boundClickOutside)
    document.addEventListener('keydown', this.boundEscapeKey)
    
    // Initialize submenu states
    this.activeSubmenu = null
    this.mobileMenuVisible = false
  }

  disconnect() {
    if (this.boundClickOutside) {
      document.removeEventListener('click', this.boundClickOutside)
    }
    if (this.boundEscapeKey) {
      document.removeEventListener('keydown', this.boundEscapeKey)
    }
  }

  // Mobile menu toggle
  toggleMobile(event) {
    event.stopPropagation()
    this.mobileMenuVisible = !this.mobileMenuVisible
    
    if (this.hasMobileMenuTarget) {
      if (this.mobileMenuVisible) {
        this.showMobileMenu()
      } else {
        this.hideMobileMenu()
      }
    }
  }

  showMobileMenu() {
    this.mobileMenuTarget.classList.remove('opacity-0', 'invisible')
    this.mobileMenuTarget.classList.add('opacity-100', 'visible')
    
    // Focus management
    const firstMenuItem = this.mobileMenuTarget.querySelector('a, button')
    if (firstMenuItem) {
      firstMenuItem.focus()
    }
  }

  hideMobileMenu() {
    this.mobileMenuTarget.classList.add('opacity-0', 'invisible')
    this.mobileMenuTarget.classList.remove('opacity-100', 'visible')
    this.mobileMenuVisible = false
    
    // Close any open mobile submenus
    this.mobileSubmenuTargets.forEach(submenu => {
      submenu.classList.add('hidden')
    })
  }

  // Desktop submenu interactions
  showSubmenu(event) {
    const submenu = event.currentTarget.parentElement.querySelector('[data-menu-target="submenu"]')
    if (submenu) {
      this.activeSubmenu = submenu
      submenu.classList.remove('opacity-0', 'invisible')
      submenu.classList.add('opacity-100', 'visible')
    }
  }

  hideSubmenu(event) {
    const submenu = event.currentTarget.parentElement.querySelector('[data-menu-target="submenu"]')
    if (submenu && submenu === this.activeSubmenu) {
      setTimeout(() => {
        if (submenu === this.activeSubmenu) {
          submenu.classList.add('opacity-0', 'invisible')
          submenu.classList.remove('opacity-100', 'visible')
          this.activeSubmenu = null
        }
      }, 100) // Small delay to allow moving to submenu
    }
  }

  toggleSubmenu(event) {
    event.stopPropagation()
    const submenu = event.currentTarget.parentElement.querySelector('[data-menu-target="submenu"]')
    
    if (submenu) {
      const isVisible = submenu.classList.contains('opacity-100')
      
      // Close other submenus first
      this.submenuTargets.forEach(otherSubmenu => {
        if (otherSubmenu !== submenu) {
          otherSubmenu.classList.add('opacity-0', 'invisible')
          otherSubmenu.classList.remove('opacity-100', 'visible')
        }
      })
      
      if (isVisible) {
        submenu.classList.add('opacity-0', 'invisible')
        submenu.classList.remove('opacity-100', 'visible')
        this.activeSubmenu = null
      } else {
        submenu.classList.remove('opacity-0', 'invisible')
        submenu.classList.add('opacity-100', 'visible')
        this.activeSubmenu = submenu
      }
    }
  }

  // Mobile submenu toggle
  toggleMobileSubmenu(event) {
    event.stopPropagation()
    const button = event.currentTarget
    const submenu = button.parentElement.querySelector('[data-menu-target="mobileSubmenu"]')
    const arrow = button.querySelector('svg')
    
    if (submenu) {
      const isHidden = submenu.classList.contains('hidden')
      
      if (isHidden) {
        submenu.classList.remove('hidden')
        if (arrow) {
          arrow.classList.add('rotate-180')
        }
      } else {
        submenu.classList.add('hidden')
        if (arrow) {
          arrow.classList.remove('rotate-180')
        }
      }
    }
  }

  // Handle clicks outside menu to close
  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      // Close mobile menu
      if (this.mobileMenuVisible) {
        this.hideMobileMenu()
      }
      
      // Close desktop submenus
      this.submenuTargets.forEach(submenu => {
        submenu.classList.add('opacity-0', 'invisible')
        submenu.classList.remove('opacity-100', 'visible')
      })
      this.activeSubmenu = null
    }
  }

  // Handle escape key
  handleEscapeKey(event) {
    if (event.key === 'Escape') {
      if (this.mobileMenuVisible) {
        this.hideMobileMenu()
        // Return focus to mobile button
        if (this.hasMobileButtonTarget) {
          this.mobileButtonTarget.focus()
        }
      }
      
      // Close desktop submenus
      if (this.activeSubmenu) {
        this.activeSubmenu.classList.add('opacity-0', 'invisible')
        this.activeSubmenu.classList.remove('opacity-100', 'visible')
        this.activeSubmenu = null
      }
    }
  }

  // Keep submenu open when hovering over it
  keepSubmenuOpen(event) {
    // This is handled by CSS hover states and the slight delay in hideSubmenu
  }
}