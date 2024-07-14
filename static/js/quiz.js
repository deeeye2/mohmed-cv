const quizContainer = document.getElementById('quiz-container');
const resultsContainer = document.getElementById('results');
const submitButton = document.getElementById('submit');

const myQuestions = [
    {
        question: "What does CI/CD stand for?",
        answers: {
            a: "Continuous Integration/Continuous Deployment",
            b: "Continuous Improvement/Continuous Delivery",
            c: "Constant Integration/Constant Delivery"
        },
        correctAnswer: "a"
    },
    {
        question: "Which tool is commonly used for containerization?",
        answers: {
            a: "Jenkins",
            b: "Docker",
            c: "Kubernetes"
        },
        correctAnswer: "b"
    },
    {
        question: "What is Kubernetes used for?",
        answers: {
            a: "Version Control",
            b: "Configuration Management",
            c: "Container Orchestration"
        },
        correctAnswer: "c"
    },
    {
        question: "Which of the following is a configuration management tool?",
        answers: {
            a: "Ansible",
            b: "Prometheus",
            c: "Grafana"
        },
        correctAnswer: "a"
    },
    {
        question: "What is the purpose of a load balancer?",
        answers: {
            a: "Distribute network traffic across multiple servers",
            b: "Monitor server performance",
            c: "Store configuration data"
        },
        correctAnswer: "a"
    },
    {
        question: "Which cloud platform is commonly used for DevOps?",
        answers: {
            a: "AWS",
            b: "Azure",
            c: "Both A and B"
        },
        correctAnswer: "c"
    },
    {
        question: "What is Jenkins used for?",
        answers: {
            a: "Code Quality Analysis",
            b: "Continuous Integration",
            c: "Server Monitoring"
        },
        correctAnswer: "b"
    },
    {
        question: "What does IaC stand for?",
        answers: {
            a: "Infrastructure as Code",
            b: "Integration as Code",
            c: "Inspection as Code"
        },
        correctAnswer: "a"
    },
    {
        question: "Which tool is used for monitoring and alerting?",
        answers: {
            a: "Grafana",
            b: "Prometheus",
            c: "Both A and B"
        },
        correctAnswer: "c"
    },
    {
        question: "Which language is commonly used for writing automation scripts?",
        answers: {
            a: "Python",
            b: "Java",
            c: "C++"
        },
        correctAnswer: "a"
    },
    {
        question: "What is the purpose of a CI/CD pipeline?",
        answers: {
            a: "To automate the testing and deployment of code",
            b: "To manage server configurations",
            c: "To monitor application performance"
        },
        correctAnswer: "a"
    },
    {
        question: "Which tool is used for version control?",
        answers: {
            a: "Git",
            b: "Docker",
            c: "Ansible"
        },
        correctAnswer: "a"
    },
    {
        question: "What is the main benefit of containerization?",
        answers: {
            a: "Improved code quality",
            b: "Consistency across different environments",
            c: "Faster application performance"
        },
        correctAnswer: "b"
    },
    {
        question: "Which tool is used for infrastructure automation?",
        answers: {
            a: "Jenkins",
            b: "Kubernetes",
            c: "Terraform"
        },
        correctAnswer: "c"
    },
    {
        question: "What is the purpose of a reverse proxy?",
        answers: {
            a: "To hide the origin server's identity",
            b: "To improve security and performance",
            c: "Both A and B"
        },
        correctAnswer: "c"
    },
    {
        question: "Which tool is used for log management and analysis?",
        answers: {
            a: "ELK Stack",
            b: "Nagios",
            c: "Grafana"
        },
        correctAnswer: "a"
    },
    {
        question: "What does SRE stand for?",
        answers: {
            a: "Site Reliability Engineering",
            b: "System Reliability Engineering",
            c: "Service Reliability Engineering"
        },
        correctAnswer: "a"
    },
    {
        question: "What is the purpose of continuous monitoring?",
        answers: {
            a: "To detect and resolve issues quickly",
            b: "To automate deployments",
            c: "To manage infrastructure"
        },
        correctAnswer: "a"
    },
    {
        question: "Which tool is used for orchestration?",
        answers: {
            a: "Kubernetes",
            b: "Jenkins",
            c: "Docker"
        },
        correctAnswer: "a"
    },
    {
        question: "What does YAML stand for?",
        answers: {
            a: "Yet Another Markup Language",
            b: "YAML Ain't Markup Language",
            c: "Yet Another Management Language"
        },
        correctAnswer: "b"
    }
];

function buildQuiz() {
    const output = [];

    myQuestions.forEach((currentQuestion, questionNumber) => {
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
            `<div class="question"> ${currentQuestion.question} </div>
            <div class="answers"> ${answers.join('')} </div>`
        );
    });

    quizContainer.innerHTML = output.join('');
}

function showResults() {
    const answerContainers = quizContainer.querySelectorAll('.answers');
    let numCorrect = 0;

    myQuestions.forEach((currentQuestion, questionNumber) => {
        const answerContainer = answerContainers[questionNumber];
        const selector = `input[name=question${questionNumber}]:checked`;
        const userAnswer = (answerContainer.querySelector(selector) || {}).value;

        if (userAnswer === currentQuestion.correctAnswer) {
            numCorrect++;
            answerContainers[questionNumber].style.color = 'lightgreen';
        } else {
            answerContainers[questionNumber].style.color = 'red';
        }
    });

    resultsContainer.innerHTML = `${numCorrect} out of ${myQuestions.length}`;
}

buildQuiz();

submitButton.addEventListener('click', showResults);


buildQuiz();

submitButton.addEventListener('click', showResults);
