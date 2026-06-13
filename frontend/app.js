let customers = [];
let lessons = [];

const SUPABASE_URL = "https://vvabnyrgongzakzpnqoj.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2YWJueXJnb25nemFrenBucW9qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA5NjY0MzYsImV4cCI6MjA5NjU0MjQzNn0.NdoZwgVueojpeCAI3JVcSh9cfuDfy4F8hwGYZ4new_c";
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const totalLessonsEl = document.getElementById("totalLessons");
const completedLessonsEl = document.getElementById("completedLessons");
const noShowLessonsEl = document.getElementById("noShowLessons");
const outstandingFeesEl = document.getElementById("outstandingFees");
const syncNoteEl = document.getElementById("syncNote");

const customerTableBody = document.getElementById("customerTableBody");
const lessonTableBody = document.getElementById("lessonTableBody");

const addCustomerForm = document.getElementById("addCustomerForm");
const updateCustomerForm = document.getElementById("updateCustomerForm");
const addLessonForm = document.getElementById("addLessonForm");
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
            "<td>" +
            "<button type='button' class='editCustomerBtn' data-id='" + c.customer_id + "'>Edit</button> " +
            "<button type='button' class='deleteCustomerBtn' data-id='" + c.customer_id + "'>Delete</button>" +
            "</td>";

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
            "<td>" + (l.vehicle_id || "") + "</td>" +
            "<td>" + l.lesson_date + "</td>" +
            "<td>" + l.lesson_time + "</td>" +
            "<td>" + l.lesson_status_code + "</td>" +
            "<td>" + money(l.price || 0) + "</td>" +
            "<td>" +
            "<button type='button' class='editLessonBtn' data-id='" + l.lesson_id + "'>Edit</button> " +
            "<button type='button' class='deleteLessonBtn' data-id='" + l.lesson_id + "'>Delete</button>" +
            "</td>";

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

function loadCustomers() {
    return supabaseClient
        .from("customers")
        .select("*")
        .order("customer_id", { ascending: true });
}

function loadLessons() {
    return supabaseClient
        .from("lessons")
        .select("*")
        .order("lesson_id", { ascending: true });
}

function loadData() {
    console.log("loadData called");

    loadCustomers()
        .then(function (result) {
            console.log("Customers result:", result);
            if (result.error) throw result.error;
            customers = result.data || [];
            return loadLessons();
        })
        .then(function (result) {
            console.log("Lessons result:", result);
            if (result.error) throw result.error;
            lessons = result.data || [];
            if (syncNoteEl) {
                syncNoteEl.textContent = "Connected to Supabase. Loaded " + customers.length + " customers, " + lessons.length + " lessons.";
            }
            redrawEverything();
        })
        .catch(function (error) {
            console.error("Full error:", error);
            if (syncNoteEl) {
                syncNoteEl.textContent = "Error: " + (error?.message || JSON.stringify(error));
            }
        });
}

addCustomerForm.addEventListener("submit", function (event) {
    event.preventDefault();

    let newId = 1;
    for (let i = 0; i < customers.length; i += 1) {
        if (customers[i].customer_id >= newId) {
            newId = customers[i].customer_id + 1;
        }
    }

    const newCustomer = {
        customer_id: newId,
        customer_address_id: 0,
        customer_status_code: document.getElementById("customerStatus").value,
        date_became_customer: document.getElementById("customerDateBecame").value,
        date_of_birth: document.getElementById("customerDateOfBirth").value,
        first_name: document.getElementById("customerFirstName").value.trim(),
        last_name: document.getElementById("customerLastName").value.trim(),
        amount_outstanding: parseFloat(document.getElementById("customerOutstanding").value) || 0,
        email_address: document.getElementById("customerEmail").value.trim(),
        phone_number: document.getElementById("customerPhone").value.trim(),
        cell_mobile_phone_number: document.getElementById("customerCellPhone").value.trim(),
        other_customer_details: document.getElementById("customerDetails").value.trim()
    };

    supabaseClient.from("customers").insert([newCustomer]).then(function (result) {
        if (result.error) {
            alert(result.error.message);
            return;
        }

        addCustomerForm.reset();
        loadData();
    });
});

updateCustomerForm.addEventListener("submit", function (event) {
    event.preventDefault();

    const id = Number(document.getElementById("updateCustomerId").value);
    let customer = null;

    for (let i = 0; i < customers.length; i += 1) {
        if (customers[i].customer_id === id) {
            customer = customers[i];
            break;
        }
    }

    if (!customer) {
        alert("Customer not found.");
        return;
    }

    const updatedCustomer = {
        first_name: document.getElementById("updateCustomerFirstName").value.trim(),
        last_name: document.getElementById("updateCustomerLastName").value.trim(),
        email_address: document.getElementById("updateCustomerEmail").value.trim(),
        phone_number: document.getElementById("updateCustomerPhone").value.trim(),
        customer_status_code: document.getElementById("updateCustomerStatus").value,
        date_of_birth: document.getElementById("updateCustomerDateOfBirth").value,
        date_became_customer: document.getElementById("updateCustomerDateBecame").value,
        cell_mobile_phone_number: document.getElementById("updateCustomerCellPhone").value.trim(),
        amount_outstanding: parseFloat(document.getElementById("updateCustomerOutstanding").value) || 0,
        other_customer_details: document.getElementById("updateCustomerDetails").value.trim()
    };

    supabaseClient
        .from("customers")
        .update(updatedCustomer)
        .eq("customer_id", id)
        .then(function (result) {
            if (result.error) {
                alert(result.error.message);
                return;
            }

            loadData();
        });
});

addLessonForm.addEventListener("submit", function (event) {
    event.preventDefault();

    const customerId = Number(document.getElementById("addLessonCustomerId").value);
    let customer = null;

    for (let i = 0; i < customers.length; i += 1) {
        if (customers[i].customer_id === customerId) {
            customer = customers[i];
            break;
        }
    }

    if (!customer) {
        alert("Customer not found for this lesson.");
        return;
    }

    let newId = 1;
    for (let i = 0; i < lessons.length; i += 1) {
        if (lessons[i].lesson_id >= newId) {
            newId = lessons[i].lesson_id + 1;
        }
    }

    const newLesson = {
        lesson_id: newId,
        customer_id: customerId,
        staff_id: Number(document.getElementById("addLessonStaffId").value),
        vehicle_id: Number(document.getElementById("addLessonVehicleId").value),
        lesson_date: document.getElementById("addLessonDate").value,
        lesson_time: document.getElementById("addLessonTime").value,
        lesson_status_code: document.getElementById("addLessonStatus").value,
        price: Number(document.getElementById("addLessonPrice").value),
        other_lesson_details: document.getElementById("addLessonDetails").value.trim()
    };

    supabaseClient.from("lessons").insert([newLesson]).then(function (result) {
        if (result.error) {
            alert(result.error.message);
            return;
        }

        addLessonForm.reset();
        loadData();
    });
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

    const updatedLesson = {
        customer_id: Number(document.getElementById("lessonCustomerId").value),
        staff_id: Number(document.getElementById("lessonStaffId").value),
        vehicle_id: Number(document.getElementById("lessonVehicleId").value),
        lesson_date: document.getElementById("lessonDate").value,
        lesson_time: document.getElementById("lessonTime").value,
        lesson_status_code: document.getElementById("lessonStatus").value,
        price: Number(document.getElementById("lessonPrice").value),
        other_lesson_details: document.getElementById("lessonDetails").value.trim()
    };

    supabaseClient
        .from("lessons")
        .update(updatedLesson)
        .eq("lesson_id", id)
        .then(function (result) {
            if (result.error) {
                alert(result.error.message);
                return;
            }

            loadData();
        });
});

customerTableBody.addEventListener("click", function (event) {
    const target = event.target;
    if (!(target instanceof HTMLElement)) {
        return;
    }

    if (target.classList.contains("editCustomerBtn")) {
        const customerId = Number(target.dataset.id);
        for (let i = 0; i < customers.length; i += 1) {
            if (customers[i].customer_id === customerId) {
                document.getElementById("updateCustomerId").value = customers[i].customer_id;
                document.getElementById("updateCustomerFirstName").value = customers[i].first_name || "";
                document.getElementById("updateCustomerLastName").value = customers[i].last_name || "";
                document.getElementById("updateCustomerEmail").value = customers[i].email_address || "";
                document.getElementById("updateCustomerPhone").value = customers[i].phone_number || "";
                document.getElementById("updateCustomerStatus").value = customers[i].customer_status_code || "GOOD";
                document.getElementById("updateCustomerDateOfBirth").value = customers[i].date_of_birth || "";
                document.getElementById("updateCustomerDateBecame").value = customers[i].date_became_customer || "";
                document.getElementById("updateCustomerCellPhone").value = customers[i].cell_mobile_phone_number || "";
                document.getElementById("updateCustomerOutstanding").value = Number(customers[i].amount_outstanding || 0);
                document.getElementById("updateCustomerDetails").value = customers[i].other_customer_details || "";
                break;
            }
        }
        return;
    }

    if (!target.classList.contains("deleteCustomerBtn")) {
        return;
    }

    const id = Number(target.dataset.id);
    const ok = confirm("Delete customer " + id + " and their lessons?");
    if (!ok) {
        return;
    }

    supabaseClient
        .from("lessons")
        .delete()
        .eq("customer_id", id)
        .then(function (lessonResult) {
            if (lessonResult.error) {
                alert(lessonResult.error.message);
                return;
            }

            supabaseClient
                .from("customers")
                .delete()
                .eq("customer_id", id)
                .then(function (customerResult) {
                    if (customerResult.error) {
                        alert(customerResult.error.message);
                        return;
                    }

                    loadData();
                });
        });
});

lessonTableBody.addEventListener("click", function (event) {
    const target = event.target;
    if (!(target instanceof HTMLElement)) {
        return;
    }

    if (target.classList.contains("editLessonBtn")) {
        const lessonId = Number(target.dataset.id);
        for (let i = 0; i < lessons.length; i += 1) {
            if (lessons[i].lesson_id === lessonId) {
                document.getElementById("lessonId").value = lessons[i].lesson_id;
                document.getElementById("lessonCustomerId").value = lessons[i].customer_id;
                document.getElementById("lessonStaffId").value = lessons[i].staff_id;
                document.getElementById("lessonVehicleId").value = lessons[i].vehicle_id || 0;
                document.getElementById("lessonDate").value = lessons[i].lesson_date || "";
                document.getElementById("lessonTime").value = lessons[i].lesson_time || "";
                document.getElementById("lessonStatus").value = lessons[i].lesson_status_code || "SCH";
                document.getElementById("lessonPrice").value = Number(lessons[i].price || 0);
                document.getElementById("lessonDetails").value = lessons[i].other_lesson_details || "";
                break;
            }
        }
        return;
    }

    if (!target.classList.contains("deleteLessonBtn")) {
        return;
    }

    const id = Number(target.dataset.id);
    const ok = confirm("Delete lesson " + id + "?");
    if (!ok) {
        return;
    }

    supabaseClient
        .from("lessons")
        .delete()
        .eq("lesson_id", id)
        .then(function (result) {
            if (result.error) {
                alert(result.error.message);
                return;
            }

            loadData();
        });
});

loadData();
