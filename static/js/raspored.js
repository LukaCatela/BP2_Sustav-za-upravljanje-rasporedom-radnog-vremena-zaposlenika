document.addEventListener("DOMContentLoaded", function() {
  fetch("/api/raspored")
    .then(response => response.json())
    .then(data => {
      // Quick sanity check
      if (!Array.isArray(data)) {
        console.error("Expected an array but got:", data);
        return;
      }
      generateGanttChart(data);
    })
    .catch(error => console.error("Error loading schedule:", error));
});

function generateGanttChart(schedule) {
  const container = document.getElementById("gantt-container");
  container.innerHTML = "";

  // Group the data: employees[employeeKey][day] = "status"
  const employees = {};
  schedule.forEach(item => {
    const empKey = `${item.id_zaposlenik} - ${item.ime} ${item.prezime}`;
    if (!employees[empKey]) {
      employees[empKey] = {};
    }
    const day = new Date(item.datum).getDate();
    // If multiple for same day, combine or skip. We'll just pick first here:
    if (!employees[empKey][day]) {
      employees[empKey][day] = item.raspored;
    }
  });

  Object.keys(employees).forEach(empKey => {
    // A row for this employee
    const rowDiv = document.createElement("div");
    rowDiv.classList.add("gantt__row");

    // Left cell: name
    const nameDiv = document.createElement("div");
    nameDiv.classList.add("gantt__row-first");
    nameDiv.innerText = empKey;
    rowDiv.appendChild(nameDiv);

    // Right side: 31 columns
    const barContainer = document.createElement("ul");
    barContainer.classList.add("gantt__row-bars");

    for (let day = 1; day <= 31; day++) {
      const status = employees[empKey][day] || "";
      const li = document.createElement("li");
      // Place in day’s column
      li.style.gridColumn = `${day} / ${day + 1}`;
      li.innerText = status;
      li.style.backgroundColor = getColor(status);
      barContainer.appendChild(li);
    }

    rowDiv.appendChild(barContainer);
    container.appendChild(rowDiv);
  });
}



/** Map each type of status to a distinct color. */
const STATUS_COLORS = {
  "jutarnja":   "#4caf50",
  "popodnevna": "#ff9800",
  "noćna":      "#9c27b0"
};

function getColor(status) {
  return STATUS_COLORS[status] || "#607d8b"; // fallback
}
