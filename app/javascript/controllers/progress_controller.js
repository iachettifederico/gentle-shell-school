import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["enrollButton", "student", "studentId", "instructionsUrl", "forgetButton", "lesson", "completion"]

  connect() {
    const studentId = localStorage.getItem("studentId")
    if (studentId) {
      this.showStudent(studentId)
      this.fetchProgress(studentId)
    }
  }

  async enroll() {
    const response = await fetch("/api/enroll", { method: "POST" })
    if (!response.ok) return

    const enrollment = await response.json()
    localStorage.setItem("studentId", enrollment.studentId)
    this.showStudent(enrollment.studentId)
    this.showProgress(enrollment.progress)
  }

  forget() {
    localStorage.removeItem("studentId")
    this.enrollButtonTarget.hidden = false
    this.studentTarget.hidden = true
    this.showProgress({ completedLessons: [] })
  }

  async fetchProgress(studentId) {
    const response = await fetch(`/api/progress/${encodeURIComponent(studentId)}`)
    if (response.status === 400 || response.status === 404) {
      this.forget()
      return
    }
    if (response.ok) this.showProgress(await response.json())
  }

  showStudent(studentId) {
    this.enrollButtonTarget.hidden = true
    this.studentTarget.hidden = false
    this.studentIdTarget.textContent = studentId
    this.instructionsUrlTarget.href = `/api/instructions/${encodeURIComponent(studentId)}`
    this.instructionsUrlTarget.textContent = this.instructionsUrlTarget.href
  }

  showProgress(progress) {
    const completedSlugs = progress.completedLessons.map((completion) => completion.slug)
    this.completionTargets.forEach((completion) => {
      completion.hidden = !completedSlugs.includes(completion.dataset.lessonSlug)
    })
  }
}
