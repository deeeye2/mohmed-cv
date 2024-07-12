const quizData = [
    {
        question: "What is CI/CD?",
        answers: {
            a: "Continuous Integration/Continuous Deployment",
            b: "Continuous Improvement/Continuous Development",
            c: "Continuous Integration/Continuous Delivery",
            d: "Continuous Implementation/Continuous Deployment"
        },
        correctAnswer: "c"
    },
    {
        question: "Which tool is used for containerization?",
        answers: {
            a: "Kubernetes",
            b: "Docker",
            c: "Jenkins",
            d: "Ansible"
        },
        correctAnswer: "b"
    },
    {
        question: "Which tool is used for orchestration?",
        answers: {
            a: "Kubernetes",
            b: "Docker",
            c: "Jenkins",
            d: "Puppet"
        },
        correctAnswer: "a"
    },
    {
        question: "What is the purpose of Ansible?",
        answers: {
            a: "Containerization",
            b: "Orchestration",
            c: "Continuous Integration",
            d: "Configuration Management"
        },
        correctAnswer: "d"
    },
    {
        question: "What is Terraform used for?",
        answers: {
            a: "Continuous Integration",
            b: "Configuration Management",
            c: "Infrastructure as Code",
            d: "Container Orchestration"
        },
        correctAnswer: "c"
    },
    {
        question: "Which of the following is a monitoring tool?",
        answers: {
            a: "Jenkins",
            b: "Prometheus",
            c: "Docker",
            d: "Ansible"
        },
        correctAnswer: "b"
    },
    {
        question: "Which tool is used for version control?",
        answers: {
            a: "Jenkins",
            b: "Kubernetes",
            c: "Git",
            d: "Ansible"
        },
        correctAnswer: "c"
    },
    {
        question: "What does CI stand for?",
        answers: {
            a: "Continuous Implementation",
            b: "Continuous Integration",
            c: "Continuous Installation",
            d: "Continuous Iteration"
        },
        correctAnswer: "b"
    },
    {
        question: "Which tool is used for container orchestration?",
        answers: {
            a: "Kubernetes",
            b: "Docker",
            c: "Jenkins",
            d: "Git"
        },
        correctAnswer: "a"
    },
    {
        question: "What does CD stand for in CI/CD?",
        answers: {
            a: "Continuous Development",
            b: "Continuous Delivery",
            c: "Continuous Deployment",
            d: "Both B and C"
        },
        correctAnswer: "d"
    }
    // Add more questions up to 20
];

const quizContainer = document.getElementById('quiz');
const resultsContainer = document.getElementById('results');
const submitButton = document.getElementById('submit');

function buildQuiz() {
    const output = [];

    quizData.forEach((currentQuestion, questionNumber) => {
        const answers = [];
        for (letter in currentQuestion.answers) {
            answers.push(
                `<label>
                    <input type="radio" name="question${questionNumber}" value="${letter}">
                    ${letter} :
                    ${currentQuestion.answers[letter]}
                </label>`
            );
        }

        output.push(
            `<div class="question">${currentQuestion.question}</div>
            <div class="answers">${answers.join('')}</div>`
        );
    });

    quizContainer.innerHTML = output.join('');
}

function showResults() {
    const answerContainers = quizContainer.querySelectorAll('.answers');
    let numCorrect = 0;

    quizData.forEach((currentQuestion, questionNumber) => {
        const answerContainer = answerContainers[questionNumber];
        const selector = `input[name=question${questionNumber}]:checked`;
        const userAnswer = (answerContainer.querySelector(selector) || {}).value;

        if (userAnswer === currentQuestion.correctAnswer) {
            numCorrect++;
            answerContainers[questionNumber].style.color = 'green';
        } else {
            answerContainers[questionNumber].style.color = 'red';
        }
    });

    resultsContainer.innerHTML = `${numCorrect} out of ${quizData.length}`;
}

buildQuiz();

submitButton.addEventListener('click', showResults);
