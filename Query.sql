CREATE OR ALTER TRIGGER UpdateQuiz
ON StudentDoQuiz
AFTER INSERT
AS
BEGIN
    -- Update the quiz record for the student
    UPDATE StudentDoQuiz
    SET 
        Score = CASE 
                    WHEN Score IS NULL THEN INSERTED.Score 
                    WHEN Quiz.CalQuizStyle = 'AVG' THEN (Score * Attempts + INSERTED.Score) / (Attempts + 1)
                    WHEN Quiz.CalQuizStyle = 'MAX' THEN CASE 
                                                            WHEN Score > INSERTED.Score THEN Score 
                                                            ELSE INSERTED.Score 
                                                        END
                END,
        State = 'Y', 
        Attempts = CASE 
                      WHEN Attempts IS NULL OR Attempts = 0 THEN 1
                      ELSE Attempts + 1 
                   END
    FROM StudentDoQuiz
    INNER JOIN INSERTED ON StudentDoQuiz.MSSV = INSERTED.MSSV AND StudentDoQuiz.QuizID = INSERTED.QuizID;
END;
-- Insert new records for new MSSV and QuizID
    INSERT INTO StudentDoQuiz (MSSV, QuizID, Score, State, Attempts)
    SELECT MSSV, QuizID, Score, 'Y', 1
    FROM INSERTED
    WHERE NOT EXISTS (
        SELECT 1 FROM StudentDoQuiz
        WHERE StudentDoQuiz.MSSV = INSERTED.MSSV AND StudentDoQuiz.QuizID = INSERTED.QuizID
    );
