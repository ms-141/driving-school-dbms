let customers = [];
let lessons = [];

const totalLessonsEl = document.getElementById("totalLessons");
const completedLessonsEl = document.getElementById("completedLessons");
const noShowLessonsEl = document.getElementById("noShowLessons");
const outstandingFeesEl = document.getElementById("outstandingFees");
const syncNoteEl = document.getElementById("syncNote");

const customerTableBody = document.getElementById("customerTableBody");
const lessonTableBody = document.getElementById("lessonTableBody");

const addCustomerForm = document.getElementById("addCustomerForm");
const updateLessonForm = document.getElementById("updateLessonForm");

function money(value) {
    return "$" + Number(value).toFixed(2);
}

function drawCustomers() {
    customerTableBody.innerHTML = "";

    for (let i = 0; i < customers.length; i += 1) {
        const c = customers[i];
        const row = document.createElement("tr");

        row.innerHTML =
            "<td>" + c.customer_id + "</td>" +
            "<td>" + c.first_name + " " + c.last_name + "</td>" +
            "<td>" + c.customer_status_code + "</td>" +
            "<td>" + money(c.amount_outstanding || 0) + "</td>" +
            "<td><button type='button' class='deleteCustomerBtn' data-id='" + c.customer_id + "'>Delete</button></td>";

        customerTableBody.appendChild(row);
    }
}

function drawLessons() {
    lessonTableBody.innerHTML = "";

    for (let i = 0; i < lessons.length; i += 1) {
        const l = lessons[i];
        const row = document.createElement("tr");

        row.innerHTML =
            "<td>" + l.lesson_id + "</td>" +
            "<td>" + l.customer_id + "</td>" +
            "<td>" + l.staff_id + "</td>" +
            "<td>" + l.lesson_date + "</td>" +
            "<td>" + l.lesson_time + "</td>" +
            "<td>" + l.lesson_status_code + "</td>" +
            "<td>" + money(l.price || 0) + "</td>";

        lessonTableBody.appendChild(row);
    }
}

function drawReports() {
    let completed = 0;
    let noShow = 0;
    let outstanding = 0;

    for (let i = 0; i < lessons.length; i += 1) {
        const code = String(lessons[i].lesson_status_code || "").toUpperCase();
        if (code === "COMP" || code === "COMPLETED") {
            completed += 1;
        }
        if (code === "NOSH" || code === "NO_SHOW" || code === "NO-SHOW") {
            noShow += 1;
        }
    }

    for (let i = 0; i < customers.length; i += 1) {
        outstanding += Number(customers[i].amount_outstanding || 0);
    }

    totalLessonsEl.textContent = String(lessons.length);
    completedLessonsEl.textContent = String(completed);
    noShowLessonsEl.textContent = String(noShow);
    outstandingFeesEl.textContent = money(outstanding);
}

function redrawEverything() {
    drawCustomers();
    drawLessons();
    drawReports();
}

addCustomerForm.addEventListener("submit", function (event) {
    event.preventDefault();

    let nextId = 1;
    for (let i = 0; i < customers.length; i += 1) {
        if (customers[i].customer_id >= nextId) {
            nextId = customers[i].customer_id + 1;
        }
    }

    const newCustomer = {
        customer_id: nextId,
        customer_address_id: 0,
        customer_status_code: document.getElementById("customerStatus").value,
        date_became_customer: new Date().toISOString().slice(0, 10),
        date_of_birth: "2000-01-01",
        first_name: document.getElementById("customerFirstName").value.trim(),
        last_name: document.getElementById("customerLastName").value.trim(),
        amount_outstanding: 0,
        email_address: document.getElementById("customerEmail").value.trim(),
        phone_number: document.getElementById("customerPhone").value.trim(),
        cell_mobile_phone_number: "",
        other_customer_details: "Added from form"
    };

    customers.push(newCustomer);
    addCustomerForm.reset();
    redrawEverything();
});

updateLessonForm.addEventListener("submit", function (event) {
    event.preventDefault();

    const id = Number(document.getElementById("lessonId").value);
    let lessonFound = null;

    for (let i = 0; i < lessons.length; i += 1) {
        if (lessons[i].lesson_id === id) {
            lessonFound = lessons[i];
            break;
        }
    }

    if (!lessonFound) {
        alert("Lesson not found.");
        return;
    }

    lessonFound.lesson_date = document.getElementById("lessonDate").value;
    lessonFound.lesson_time = document.getElementById("lessonTime").value;
    lessonFound.lesson_status_code = document.getElementById("lessonStatus").value;
    lessonFound.price = Number(document.getElementById("lessonPrice").value);

    redrawEverything();
});

customerTableBody.addEventListener("click", function (event) {
    const target = event.target;
    if (!(target instanceof HTMLElement)) {
        return;
    }
    if (!target.classList.contains("deleteCustomerBtn")) {
        return;
    }

    const id = Number(target.dataset.id);
    const ok = confirm("Delete customer " + id + "?");
    if (!ok) {
        return;
    }

    customers = customers.filter(function (c) {
        return c.customer_id !== id;
    });

    redrawEverything();
});

fetch("./test.json")
    .then(function (response) {
        return response.json();
    })
    .then(function (data) {
        customers = data.drivingSchool.customers || [];
        lessons = data.drivingSchool.lessons || [];
        syncNoteEl.textContent = "Connected to ./test.json. Edits are saved in local memory";
        redrawEverything();
    });
