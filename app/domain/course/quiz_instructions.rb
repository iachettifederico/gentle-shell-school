module Course
  # Shared teach -> quiz -> verify boilerplate appended to the agent
  # instructions of every quiz lesson, so lesson files stay focused on their
  # own topics.
  module QuizInstructions
    TEXT = <<~TEXT.squeeze(" ").tr("\n", " ").strip
      Teach this lesson conversationally before quizzing or verifying. Cover each
      topic one at a time, pausing for the student to acknowledge before moving on.
      Once you've covered all the material, quiz the student with a single
      ask_user_question call holding one question per topic, each with four
      plausible options. Randomize the order of the options so the correct answer
      is not always first. After the student answers, explain any wrong answers in
      a friendly way, then give a brief summary of what they missed. Then verify
      completion as described above. Mark the lesson complete regardless of quiz
      score: the quiz is for learning, not gatekeeping.
    TEXT
  end
end
