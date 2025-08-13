import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mention-autocomplete"
export default class extends Controller {

  static targets = ["textarea", "dropdown"]

  connect() {
    this.allUsernames = []
    this.fetchUsernames()
  }

  fetchUsernames(){
    fetch("/users/all_usernames")
      .then(response => response.json())
      .then(data=>{
        this.allUsernames = data
        console.log("Fetched usernames:", this.allUsernames)
      })
  }

  onInput(event){
    const cursorPos = this.textareaTarget.selectionStart
    const textBeforeCursor = this.textareaTarget.value.slice(0,cursorPos)
    const match = textBeforeCursor.match(/@(\w*)$/)
    if(match){
      this.showDropdown(match[1], cursorPos)
    }
    else {
      this.hideDropdown()
    }
  }

  showDropdown(partialUsername,cursorPos){
    this.dropdownTarget.innerHTML = ""

    const filtered = this.allUsernames.filter(username =>
      username.toLowerCase().startsWith(partialUsername.toLowerCase())
    )
    console.log("Filtered usernames:", filtered)
    
    filtered.forEach(username => {
      const li = document.createElement("li")
      li.textContent = username
      li.addEventListener("mousedown", event =>{
        event.preventDefault()

        const beforeAt = this.textareaTarget.value.slice(0,cursorPos)

        const match = beforeAt.match(/@(\w*)$/)
        if(!match) return
          const start = match.index
          const beforeMention = beforeAt.slice(0,start)
  
        const afterCursor = this.textareaTarget.value.slice(cursorPos)

        this.textareaTarget.value = beforeMention + "@" + username + "" + afterCursor
        this.textareaTarget.focus()
        this.hideDropdown()
      })

      this.dropdownTarget.appendChild(li)
      console.log(this.dropdownTarget.innerHTML)
    })
    this.positionDropdown()
    this.dropdownTarget.style.display = "block"
  }

  hideDropdown() {
    this.dropdownTarget.style.display = "none"
  }

 positionDropdown() {
  const containerRect = this.textareaTarget.parentElement.getBoundingClientRect()
  const textareaRect = this.textareaTarget.getBoundingClientRect()

  this.dropdownTarget.style.position = "absolute"
  this.dropdownTarget.style.top = (textareaRect.bottom - containerRect.top) + "px"
  this.dropdownTarget.style.left = (textareaRect.left - containerRect.left) + "px"
  this.dropdownTarget.style.width = textareaRect.width + "px"
 }
}
