import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["enrollButton", "student", "studentId", "instructionsUrl", "forgetButton", "lesson", "completion", "summary", "continue", "enrollmentPrompt", "lessonProgress", "status", "completionButton"]
  static values = { lessonSlug: String }

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
    if (this.hasEnrollButtonTarget) this.enrollButtonTarget.hidden = false
    if (this.hasStudentTarget) this.studentTarget.hidden = true
    if (this.hasEnrollmentPromptTarget) this.enrollmentPromptTarget.hidden = false
    if (this.hasLessonProgressTarget) this.lessonProgressTarget.hidden = true
    this.showCompletions([])
    this.hideModuleCounts()
  }

  async fetchProgress(studentId) {
    const response = await fetch(`/api/progress/${encodeURIComponent(studentId)}`)
    if (this.staleStudent(response)) return
    if (response.ok) this.showProgress(await response.json())
  }

  async toggleCompletion() {
    const studentId = localStorage.getItem("studentId")
    if (!studentId || !this.hasLessonSlugValue) return

    const completed = this.completionButtonTarget.textContent === "Mark not complete"
    const response = await fetch(`/api/progress/${encodeURIComponent(studentId)}`, this.progressRequest(completed))
    if (this.staleStudent(response)) return
    if (response.ok) this.showProgress(await response.json())
  }

  copy(event) {
    navigator.clipboard.writeText(event.currentTarget.dataset.prompt)
    event.currentTarget.textContent = "Copied"
    setTimeout(() => { event.currentTarget.textContent = "Copy" }, 1200)
  }

  showStudent(studentId) {
    if (this.hasEnrollButtonTarget) this.enrollButtonTarget.hidden = true
    if (this.hasStudentTarget) this.studentTarget.hidden = false
    if (this.hasStudentIdTarget) this.studentIdTarget.textContent = studentId
    if (this.hasInstructionsUrlTarget) this.showInstructionsUrl(studentId)
  }

  showProgress(progress) {
    const completions = progress.completedLessons
    const completedSlugs = completions.map((completion) => completion.slug)
    this.showCompletions(completions)
    this.showLessonProgress(completions)
    this.showHomeProgress(completedSlugs)
  }

  progressRequest(completed) {
    const options = { method: completed ? "DELETE" : "PUT", headers: { "Content-Type": "application/json" } }
    options.body = JSON.stringify(completed ? { lessonSlug: this.lessonSlugValue } : { lessonSlug: this.lessonSlugValue, source: "browser" })
    return options
  }

  staleStudent(response) {
    if (response.status !== 400 && response.status !== 404) return false

    this.forget()
    return true
  }

  showInstructionsUrl(studentId) {
    const url = `/api/instructions/${encodeURIComponent(studentId)}`
    this.instructionsUrlTarget.href = url
    this.instructionsUrlTarget.textContent = new URL(url, window.location.origin).href
  }

  showCompletions(completions) {
    this.completionTargets.forEach((completion) => {
      const completed = completions.find((item) => item.slug === completion.dataset.lessonSlug)
      completion.hidden = !completed
      if (completed) this.setCompletionLabel(completion, completed)
    })
  }

  showLessonProgress(completions) {
    if (!this.hasLessonProgressTarget) return

    const completion = completions.find((item) => item.slug === this.lessonSlugValue)
    this.enrollmentPromptTarget.hidden = true
    this.lessonProgressTarget.hidden = false
    this.statusTarget.textContent = completion ? this.completionLabel(completion) : "Not completed yet"
    this.completionButtonTarget.textContent = completion ? "Mark not complete" : "Mark complete"
  }

  setCompletionLabel(element, completion) {
    const label = this.completionLabel(completion)
    element.textContent = label
    element.setAttribute("aria-label", label)
  }

  completionLabel(completion) {
    if (!completion.evidence) return "✓"

    return completion.evidence.verifiedBy === "independent-verifier" ? "Independently verified" : "Verified"
  }

  showHomeProgress(completedSlugs) {
    if (!this.hasSummaryTarget) return

    const total = this.lessonTargets.length
    this.summaryTarget.textContent = completedSlugs.length === total ? "All lessons complete." : `${completedSlugs.length} of ${total} lessons complete`
    this.showContinueLink(completedSlugs)
    this.showModuleCounts(completedSlugs)
  }

  showContinueLink(completedSlugs) {
    const nextLesson = this.lessonTargets.find((lesson) => !completedSlugs.includes(lesson.dataset.lessonSlug))
    this.continueTarget.hidden = !nextLesson
    if (!nextLesson) return

    const link = this.continueTarget.querySelector("a")
    const lessonLink = nextLesson.querySelector("a[data-lesson]")
    link.href = lessonLink.href
    link.textContent = `Continue with: ${lessonLink.textContent.trim()}`
  }

  showModuleCounts(completedSlugs) {
    this.element.querySelectorAll("[data-progress-module-count]").forEach((count) => {
      const moduleLessons = this.lessonTargets.filter((lesson) => lesson.dataset.moduleName === count.dataset.moduleName)
      const completed = moduleLessons.filter((lesson) => completedSlugs.includes(lesson.dataset.lessonSlug)).length
      count.textContent = `${completed}/${count.dataset.moduleTotal} done`
      count.hidden = false
    })
  }

  hideModuleCounts() {
    this.element.querySelectorAll("[data-progress-module-count]").forEach((count) => { count.hidden = true })
  }
}
