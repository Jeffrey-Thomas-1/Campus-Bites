import "dotenv/config";
import express from "express";
import cors from "cors";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import mysql from "mysql2/promise";

const app = express();
const port = Number(process.env.PORT || 3000);
const jwtSecret = process.env.JWT_SECRET;

if (!jwtSecret) {
  throw new Error("JWT_SECRET is required in backend/.env");
}

const pool = mysql.createPool({
  host: process.env.MYSQL_HOST || "localhost",
  port: Number(process.env.MYSQL_PORT || 3306),
  user: process.env.MYSQL_USER || "root",
  password: process.env.MYSQL_PASSWORD || "",
  database: process.env.MYSQL_DATABASE || "campusBites",
  ssl: process.env.MYSQL_SSL === "true" ? { rejectUnauthorized: true } : undefined,
  waitForConnections: true,
  connectionLimit: 10
});

app.use(cors());
app.use(express.json());
app.use((req, _res, next) => {
  if (!req.url.startsWith("/api")) req.url = `/api${req.url}`;
  next();
});

app.get("/api/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ ok: true, database: "campusBites" });
  } catch (error) {
    console.error("Database health check failed:", error);
    res.status(503).json({ ok: false, message: "Database unavailable" });
  }
});

app.get("/api/menu", async (_req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT `Food Name` AS foodName, `Food type` AS foodType, `Price` AS price, `rating`, `Prep time` AS prepTime, `in stock` AS inStock, `stock_number` AS stockNumber FROM `MENU` ORDER BY `Food Name`"
    );
    res.json(rows);
  } catch (error) {
    console.error("Menu query failed:", error);
    res.status(500).json({ message: "Unable to load menu" });
  }
});

app.post("/api/auth/signup", async (req, res) => {
  const { fullName, studentId, email, password } = req.body;
  if (!fullName || !email || !password || password.length <= 8 || !/\d/.test(password)) {
    return res.status(400).json({ message: "Name, email, and a password longer than 8 characters with a number are required" });
  }
  try {
    const passwordHash = await bcrypt.hash(password, 12);
    const generatedStudentId = studentId?.trim() || `S-${Date.now().toString(36)}`;
    const [result] = await pool.execute(
      "INSERT INTO `Users` (`full_name`, `student_id`, `email`, `password_hash`) VALUES (?, ?, ?, ?)",
      [fullName.trim(), generatedStudentId, email.trim().toLowerCase(), passwordHash]
    );
    res.status(201).json({ userId: result.insertId, message: "Account created" });
  } catch (error) {
    if (error.code === "ER_DUP_ENTRY") {
      return res.status(409).json({ message: "That email or student ID is already registered" });
    }
    console.error("Signup failed:", error);
    res.status(500).json({ message: "Unable to create account" });
  }
});

app.post("/api/auth/login", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ message: "Email and password are required" });
  try {
    const [rows] = await pool.execute(
      "SELECT `user_id`, `full_name`, `student_id`, `email`, `password_hash`, `role` FROM `Users` WHERE `email` = ? LIMIT 1",
      [email.trim().toLowerCase()]
    );
    const user = rows[0];
    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({ message: "Invalid email or password" });
    }
    const token = jwt.sign({ userId: user.user_id, role: user.role }, jwtSecret, { expiresIn: "2h" });
    res.json({ token, user: { id: user.user_id, fullName: user.full_name, studentId: user.student_id, email: user.email, role: user.role } });
  } catch (error) {
    console.error("Login failed:", error);
    res.status(500).json({ message: "Unable to log in" });
  }
});

if (!process.env.VERCEL) {
  app.listen(port, () => console.log(`Campus Bites API running at http://localhost:${port}`));
}

export default app;
