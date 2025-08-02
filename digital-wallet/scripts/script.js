/*Light-Dark Mode */
document.addEventListener("DOMContentLoaded", () => {
    const toggleBtn = document.getElementById("theme-toggle");

    //Load saved theme
    if (localStorage.getItem("theme") === "dark") {
        document.body.classList.add("dark-mode");
    }

    toggleBtn?.addEventListener("click", () => {
        document.body.classList.toggle("dark-mode");

        //Save the theme
        const mode = document.body.classList.contains("dark-mode") ? "dark" : "light";
        localStorage.setItem("theme", mode);
    });
});

console.log("Script loaded ✅");