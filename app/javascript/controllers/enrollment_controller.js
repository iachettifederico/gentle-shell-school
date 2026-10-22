import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["switchWarning"]
  static values = { studentId: String }

  connect() {
    if (this.hasStudentIdValue) localStorage.setItem("studentId", this.studentIdValue)
    if (this.hasSwitchWarningTarget && localStorage.getItem("studentId")) this.switchWarningTarget.hidden = false
  }
}
