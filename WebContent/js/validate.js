document.querySelector("form").addEventListener("submit", function(e) {
    const amount = document.querySelector("input[name='amount']").value;
    if (amount <= 0) {
        e.preventDefault();
        alert("Amount must be greater than 0");
    }
});
    