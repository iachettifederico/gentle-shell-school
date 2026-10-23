import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["enrollButton", "student", "studentId", "forgetButton", "lesson", "completion", "summary", "continue", "enrollmentPrompt", "lessonProgress", "status", "completionButton", "completedBanner"]
  static values = { lessonSlug: String, completedLabel: String, copyLabel: String, copiedLabel: String, notCompletedLabel: String, markIncompleteLabel: String, markCompleteLabel: String, verifiedLabel: String, independentlyVerifiedLabel: String, allCompleteLabel: String, completeCountLabel: String, continueLabel: String, moduleCountLabel: String }

  connect() {
    this.adoptStudentFromUrl()
    const studentId = localStorage.getItem("studentId")
    if (studentId) {
      this.showStudent(studentId)
      this.fetchProgress(studentId)
      this.startPolling()
    }
  }

  disconnect() {
    this.stopPolling()
  }

  // The agent records completions through the API; follow them while the tab is visible.
  startPolling() {
    if (this.pollTimer) return

    this.pollTimer = setInterval(() => this.poll(), 2000)
    this.onVisible = () => { if (document.visibilityState === "visible") this.poll() }
    document.addEventListener("visibilitychange", this.onVisible)
  }

  stopPolling() {
    clearInterval(this.pollTimer)
    this.pollTimer = null
    if (this.onVisible) document.removeEventListener("visibilitychange", this.onVisible)
  }

  async poll() {
    const studentId = localStorage.getItem("studentId")
    if (!studentId) return this.stopPolling()
    if (document.visibilityState !== "visible" || this.polling) return

    this.polling = true
    try { await this.fetchProgress(studentId) } finally { this.polling = false }
  }

  async enroll() {
    const response = await fetch("/api/enroll", { method: "POST" })
    if (!response.ok) return

    const enrollment = await response.json()
    localStorage.setItem("studentId", enrollment.studentId)
    this.showStudent(enrollment.studentId)
    this.showProgress(enrollment.progress)
    this.startPolling()
  }

  forget() {
    localStorage.removeItem("studentId")
    this.stopPolling()
    if (this.hasCompletedBannerTarget) this.completedBannerTarget.hidden = true
    if (this.hasEnrollButtonTarget) this.enrollButtonTarget.hidden = false
    if (this.hasStudentTarget) this.studentTarget.hidden = true
    if (this.hasEnrollmentPromptTarget) this.enrollmentPromptTarget.hidden = false
    if (this.hasLessonProgressTarget) this.lessonProgressTarget.hidden = true
    this.showCompletions([])
    this.hideModuleCounts()
    this.fillPrompts(null)
  }

  async fetchProgress(studentId) {
    const response = await fetch(`/api/progress/${encodeURIComponent(studentId)}`)
    if (this.staleStudent(response)) return
    if (response.ok) this.showProgress(await response.json())
  }

  async toggleCompletion() {
    const studentId = localStorage.getItem("studentId")
    if (!studentId || !this.hasLessonSlugValue) return

    const completed = this.completionButtonTarget.textContent === this.markIncompleteLabelValue
    const response = await fetch(`/api/progress/${encodeURIComponent(studentId)}`, this.progressRequest(completed))
    if (this.staleStudent(response)) return
    if (response.ok) this.showProgress(await response.json())
  }

  copy(event) {
    const button = event.currentTarget
    const status = button.parentElement.querySelector("[data-copy-status]")
    navigator.clipboard.writeText(button.dataset.prompt)
    button.textContent = this.copiedLabelValue
    if (status) status.textContent = this.copiedLabelValue
    setTimeout(() => {
      button.textContent = this.copyLabelValue
      if (status) status.textContent = ""
    }, 1200)
  }

  showStudent(studentId) {
    if (this.hasEnrollButtonTarget) this.enrollButtonTarget.hidden = true
    if (this.hasStudentTarget) this.studentTarget.hidden = false
    if (this.hasStudentIdTarget) this.studentIdTarget.textContent = studentId
    this.fillPrompts(studentId)
  }

  // An agent hands the student a `?sid=<id>` link; keep the ID and drop it from the address bar.
  adoptStudentFromUrl() {
    const url = new URL(window.location.href)
    const studentId = url.searchParams.get("sid")
    if (!studentId) return

    localStorage.setItem("studentId", studentId)
    url.searchParams.delete("sid")
    window.history.replaceState(window.history.state, "", url.pathname + url.search + url.hash)
  }

  // Enrolled prompts carry the student ID; pass null to restore the anonymous prompts.
  fillPrompts(studentId) {
    this.element.querySelectorAll("[data-prompt-template]").forEach((text) => {
      if (!text.dataset.promptTemplate) return

      text.dataset.promptAnonymous ||= text.textContent
      const prompt = studentId ? text.dataset.promptTemplate.replace("{studentId}", studentId) : text.dataset.promptAnonymous
      text.textContent = prompt
      text.closest(".card").querySelector("[data-action='progress#copy']").dataset.prompt = prompt
    })
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
    this.setText(this.statusTarget, completion ? this.statusLabel(completion) : this.notCompletedLabelValue)
    this.setText(this.completionButtonTarget, completion ? this.markIncompleteLabelValue : this.markCompleteLabelValue)
    if (this.hasCompletedBannerTarget) this.completedBannerTarget.hidden = !completion
  }

  // Polling repeats every render; only touch text that changed so live regions do not re-announce it.
  setText(element, text) {
    if (element.textContent !== text) element.textContent = text
  }

  setCompletionLabel(element, completion) {
    const label = this.completionLabel(completion)
    element.textContent = label
    element.setAttribute("aria-label", completion.evidence ? label : element.dataset.completedLabel || label)
  }

  statusLabel(completion) {
    if (completion.evidence || !this.hasCompletedLabelValue) return this.completionLabel(completion)

    return `${this.completedLabelValue} ✓`
  }

  completionLabel(completion) {
    if (!completion.evidence) return "✓"

    return completion.evidence.verifiedBy === "independent-verifier" ? this.independentlyVerifiedLabelValue : this.verifiedLabelValue
  }

  showHomeProgress(completedSlugs) {
    if (!this.hasSummaryTarget) return

    const total = this.lessonTargets.length
    this.setText(this.summaryTarget, completedSlugs.length === total ? this.allCompleteLabelValue : this.completeCountLabelValue.replace("%{completed}", completedSlugs.length).replace("%{total}", total))
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
    link.textContent = this.continueLabelValue.replace("%{title}", lessonLink.textContent.trim())
  }

  showModuleCounts(completedSlugs) {
    this.element.querySelectorAll("[data-progress-module-count]").forEach((count) => {
      const moduleLessons = this.lessonTargets.filter((lesson) => lesson.dataset.moduleName === count.dataset.moduleName)
      const completed = moduleLessons.filter((lesson) => completedSlugs.includes(lesson.dataset.lessonSlug)).length
      count.textContent = this.moduleCountLabelValue.replace("%{completed}", completed).replace("%{total}", count.dataset.moduleTotal)
      count.hidden = false
    })
  }

  hideModuleCounts() {
    this.element.querySelectorAll("[data-progress-module-count]").forEach((count) => { count.hidden = true })
  }
}
