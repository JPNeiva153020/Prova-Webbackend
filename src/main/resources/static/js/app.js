document.addEventListener("DOMContentLoaded", function () {
    showToast();

    const deleteLinks = document.querySelectorAll("[data-confirm-delete]");

    deleteLinks.forEach(function (link) {
        link.addEventListener("click", function (event) {
            const message = link.getAttribute("data-confirm-delete");

            const confirmed = confirm(message || "Tem certeza que deseja remover este registro?");

            if (!confirmed) {
                event.preventDefault();
            }
        });
    });

    const numberInputs = document.querySelectorAll('input[type="number"]');

    numberInputs.forEach(function (input) {
        input.addEventListener("input", function () {
            const value = Number(input.value);

            if (input.min !== "" && value < Number(input.min)) {
                input.value = input.min;
            }

            if (input.max !== "" && value > Number(input.max)) {
                input.value = input.max;
            }
        });
    });
});

function showToast() {
    const toast = document.querySelector(".toast");

    if (!toast) {
        return;
    }

    toast.classList.add("show");

    setTimeout(function () {
        toast.classList.remove("show");
    }, 3000);
}