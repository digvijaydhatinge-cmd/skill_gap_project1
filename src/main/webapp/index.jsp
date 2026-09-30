<%@ page import="java.sql.*, java.util.*" %>
<%
    // Logic remains consistent with your provided backend
    String url = "jdbc:mysql://localhost:3306/career_guide";
    String user = "root";
    String pass = "root"; 
    
    List<String> missingSkills = new ArrayList<>();
    List<String> userSkillsList = new ArrayList<>();
    double readiness = 0;
    double weightPerSkill = 0;
    String targetRole = request.getParameter("targetRole");
    String[] selectedSkills = request.getParameterValues("userSkills");

    Map<String, String> courseLibrary = new LinkedHashMap<>();
    courseLibrary.put("Java", "Java Enterprise Edition Masterclass");
    courseLibrary.put("Python", "Python for AI and Machine Learning");
    courseLibrary.put("React", "Full-Stack Web Dev with React");
    courseLibrary.put("Node.js", "Scalable Backend Systems with Node");
    courseLibrary.put("AWS", "AWS Solutions Architect Professional");
    courseLibrary.put("Docker", "Microservices with Docker & Kubernetes");
    courseLibrary.put("SQL", "Database Design & Advanced SQL Querying");
    courseLibrary.put("JavaScript", "Modern JavaScript (ES6+) Mastery");

    if (targetRole != null && selectedSkills != null) {
        userSkillsList = Arrays.asList(selectedSkills);
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(url, user, pass);
            PreparedStatement ps = con.prepareStatement("SELECT required_skills FROM job_roles WHERE role_name=?");
            ps.setString(1, targetRole);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String[] reqArray = rs.getString("required_skills").split(",");
                int totalRequired = reqArray.length;
                weightPerSkill = 100.0 / totalRequired;
                int matched = 0;
                for (String s : reqArray) {
                    String cleanSkill = s.trim();
                    if (userSkillsList.contains(cleanSkill)) matched++;
                    else missingSkills.add(cleanSkill);
                }
                readiness = ((double) matched / totalRequired) * 100;
            }
            con.close();
        } catch (Exception e) { }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SkillBridge AI | Fluid Design</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;500;800&display=swap" rel="stylesheet">
    
    <style>
        :root {
            /* High-Responsive Color Palette */
            --grad-start: #6366f1;
            --grad-mid: #a855f7;
            --grad-end: #ec4899;
            --surface: #11111b;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--surface);
            /* Responsive dynamic background */
            background: linear-gradient(135deg, #11111b 0%, #1a1a2e 100%);
            color: #e2e8f0;
            min-height: 100vh;
            margin: 0;
            overflow-x: hidden;
        }

        /* --- Fluid Sidebar --- */
        .sidebar {
            width: 360px;
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(15px);
            border-right: 1px solid rgba(255, 255, 255, 0.1);
            padding: 40px;
            height: 100vh;
            position: sticky;
            top: 0;
        }

        .logo-header {
            font-size: 1.8rem;
            font-weight: 800;
            letter-spacing: -1px;
            background: linear-gradient(to right, var(--grad-start), var(--grad-end));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 50px;
        }

        /* --- Responsive Input Overrides --- */
        .custom-select {
            background: rgba(255, 255, 255, 0.05);
            border: 2px solid rgba(255, 255, 255, 0.1);
            color: white;
            padding: 15px;
            border-radius: 15px;
            transition: 0.3s;
        }
        .custom-select:focus {
            border-color: var(--grad-mid);
            box-shadow: 0 0 20px rgba(168, 85, 247, 0.2);
            outline: none;
        }

        .skill-pill label {
            padding: 12px 20px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        /* Cursor Hover Glow */
        .skill-pill label:hover {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--grad-mid);
            transform: scale(1.05);
            box-shadow: 0 0 15px rgba(168, 85, 247, 0.4);
        }
        .skill-pill input:checked + label {
            background: linear-gradient(to bottom right, var(--grad-start), var(--grad-mid));
            border: none;
            font-weight: 600;
        }

        /* --- Main Content --- */
        .main-panel { flex-grow: 1; padding: 60px; }

        .glass-container {
            background: rgba(255, 255, 255, 0.02);
            border-radius: 40px;
            padding: 50px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            box-shadow: 0 40px 100px rgba(0,0,0,0.4);
        }

        .progress-ui {
            width: 200px; height: 200px;
            background: radial-gradient(closest-side, var(--surface) 85%, transparent 0 100%),
                        conic-gradient(var(--grad-start) 0%, var(--grad-end) <%= readiness %>%, #2d2d3f 0);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 2.5rem; font-weight: 800;
        }

        .course-card {
            background: rgba(255, 255, 255, 0.03);
            border-left: 4px solid var(--grad-mid);
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 20px;
            transition: 0.3s;
        }
        .course-card:hover {
            background: rgba(255, 255, 255, 0.07);
            transform: translateX(15px);
        }

        /* Responsive Linear Gradient Button */
        .btn-fluid {
            background: linear-gradient(90deg, var(--grad-start), var(--grad-mid), var(--grad-end));
            background-size: 200% auto;
            border: none;
            padding: 20px;
            border-radius: 15px;
            color: white;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 2px;
            transition: 0.5s;
        }
        .btn-fluid:hover {
            background-position: right center;
            box-shadow: 0 10px 40px rgba(236, 72, 153, 0.3);
        }

        @media (max-width: 992px) {
            .sidebar { width: 100%; height: auto; border-right: none; border-bottom: 1px solid rgba(255,255,255,0.1); }
            .d-flex { flex-direction: column; }
        }
    </style>
</head>
<body>

<div class="d-flex">
    <aside class="sidebar">
        <div class="logo-header">SkillBridge AI</div>
        
        <form method="POST">
            <div class="mb-5">
                <label class="small fw-bold mb-3 opacity-50">CAREER TRAJECTORY</label>
                <select name="targetRole" class="custom-select w-100">
                    <option disabled selected>Identify Destination...</option>
                    <% String[] rNames = {"Frontend Developer", "Java Full Stack Developer", "Cloud Architect", "Data Engineer"}; 
                       for(String r : rNames) { %>
                        <option <%= r.equals(targetRole)?"selected":"" %>><%= r %></option>
                    <% } %>
                </select>
            </div>

            <div class="mb-5">
                <label class="small fw-bold mb-3 opacity-50">ACQUIRED COMPETENCIES</label>
                <div class="d-flex flex-wrap gap-2">
                    <% String[] sList = {"Java", "Python", "React", "Node.js", "AWS", "Docker", "SQL", "JavaScript"};
                       for(String s : sList) { %>
                    <div class="skill-pill">
                        <input type="checkbox" name="userSkills" value="<%= s %>" id="s-<%= s %>" 
                               <%= (userSkillsList.contains(s))?"checked":"" %> style="display:none">
                        <label for="s-<%= s %>"><%= s %></label>
                    </div>
                    <% } %>
                </div>
            </div>

            <button type="submit" class="btn-fluid w-100">Calculate Roadmap</button>
        </form>
    </aside>

    <main class="main-panel">
        <% if (targetRole != null) { %>
            <div class="glass-container">
                <div class="row align-items-center g-5">
                    <div class="col-xl-4 text-center">
                        <div class="progress-ui mx-auto"><%= (int)readiness %>%</div>
                        <h3 class="mt-4 fw-800"><%= targetRole %></h3>
                        <p class="opacity-50">Proficiency Score</p>
                    </div>
                    
                    <div class="col-xl-8">
                        <h4 class="mb-4">Skills To Acquire</h4>
                        <div class="roadmap">
                            <% if (missingSkills.isEmpty()) { %>
                                <div class="p-5 text-center bg-white bg-opacity-5 rounded-4">
                                    <h1 class="display-4">🔥</h1>
                                    <h4>Peak Performance Reach</h4>
                                </div>
                            <% } else { 
                                for(String skill : missingSkills) { %>
                                <div class="course-card d-flex justify-content-between align-items-center">
                                    <div>
                                        <div class="fw-bold fs-5"><%= courseLibrary.getOrDefault(skill, "Advanced " + skill) %></div>
                                        <div class="small opacity-40">Missing Link: <%= skill %></div>
                                    </div>
                                    <div class="text-end">
                                        <span class="badge bg-light text-dark">+<%= String.format("%.0f", weightPerSkill) %>%</span>
                                    </div>
                                </div>
                            <% } } %>
                        </div>
                    </div>
                </div>
            </div>
        <% } else { %>
            <div class="h-100 d-flex flex-column align-items-center justify-content-center text-center opacity-40">
                <div style="font-size: 8rem; filter: blur(2px);">⚛️</div>
                <h1 class="display-3 fw-800 mt-4">Bridge the Gap</h1>
                <p class="fs-5">Enter your current stack to see your personalized learning path.</p>
            </div>
        <% } %>
    </main>
</div>

</body>
</html>