<!-- shared header -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />

<link rel="stylesheet" href="../css/style.css" />

<style>
  :root {
    --main-bg: #fff;
    --main-text: #111;
    --nav-link: #111;
    --nav-link-hover-bg: #2563eb;
    --nav-link-hover-text: #fff;
    --blue: #2563eb;
    --input-bg: #e0f7fa; /* light sea blue */
    --input-text: #111;
    --input-border: #88b2e2; /* sea blue border */
    --input-placeholder: #888;
  }
  body.dark-mode {
    --main-bg: #111;
    --main-text: #fff;
    --nav-link: #fff;
    --nav-link-hover-bg: #2563eb;
    --nav-link-hover-text: #fff;
    --blue: #2563eb;
    --input-bg: #849cd9; /* deeper sea blue for dark mode */
    --input-text: #fff;
    --input-border: #87b5de;
    --input-placeholder: #e0f7fa;
  }
  body {
    background: var(--main-bg) !important;
    color: var(--main-text) !important;
    transition: background 0.3s, color 0.3s;
  }
  input,
  textarea,
  select {
    background: var(--input-bg) !important;
    color: var(--input-text) !important;
    border: 1.5px solid var(--input-border) !important;
    transition: background 0.3s, color 0.3s, border 0.3s;
    box-shadow: 0 1px 4px rgba(204, 199, 241, 0.08);
  }
  input:focus,
  textarea:focus,
  select:focus {
    outline: none;
    border-color: #5d5d82;
    box-shadow: 0 0 0 2px rgba(38, 198, 218, 0.15);
  }
  input::placeholder,
  textarea::placeholder {
    color: var(--input-placeholder) !important;
    opacity: 1;
  }
  .nav {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: fixed;
    top: 0;
    left: 0;
    background: inherit;
    padding: 0.4rem 1rem;
    min-height: 40px;
    z-index: 1000;
    box-shadow: none;
  }
  .nav-left,
  .nav-right {
    display: flex;
    align-items: center;
  }
  .nav a {
    color: var(--nav-link);
    text-decoration: none;
    font-weight: 500;
    padding: 0.5rem 1.2rem;
    border-radius: 5px;
    margin: 0 0.5rem;
    transition: background 0.2s, color 0.2s;
    background: none;
    white-space: nowrap;
  }
  .nav a:hover {
    background: var(--nav-link-hover-bg);
    color: var(--nav-link-hover-text);
  }
  .blue-text {
    color: var(--blue) !important;
  }
</style>

<div
  class="nav"
  style="flex-direction: column; align-items: stretch; position: static"
>
  <div
    style="display: flex; justify-content: space-between; align-items: center"
  >
    <div class="nav-left">
      <% if (session != null && session.getAttribute("userId") != null) { %>
      <a href="../pages/dashboard.jsp">Dashboard</a>
      <% } %>
    </div>
    <div class="nav-right">
      <% if (session != null && session.getAttribute("userId") != null) { %>
      <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
      <% } %>
    </div>
  </div>
  <div
    style="
      display: flex;
      justify-content: flex-end;
      align-items: center;
      margin-top: 0.2rem;
    "
  >
    <button
      onclick="toggleTheme()"
      style="
        font-size: 1.1rem;
        background: none;
        border: none;
        cursor: pointer;
        color: var(--nav-link);
      "
    >
      🌓 Toggle Dark Mode
    </button>
  </div>
</div>

<script>
  function setTextColors() {
    // No-op: CSS variables now handle all color changes, including forms
  }
  function toggleTheme() {
    document.body.classList.toggle("dark-mode");
    if (document.body.classList.contains("dark-mode")) {
      localStorage.setItem("theme", "dark");
    } else {
      localStorage.setItem("theme", "light");
    }
    setTextColors();
  }
  // Load saved preference on page load
  window.onload = function () {
    if (localStorage.getItem("theme") === "dark") {
      document.body.classList.add("dark-mode");
    }
    setTextColors();
  };
</script>
