const express = require("express");
const bodyParser = require("body-parser");
const { SerialPort } = require("serialport");

const app = express();
app.use(bodyParser.json());

const arduinoPort = new SerialPort({ path: "COM3", baudRate: 9600 });

app.post("/send-sms", (req, res) => {
  const { number, message } = req.body;
  if (!number || !message) return res.status(400).json({ error: "number and message required" });

  const cmd = `${number}|${message}\n`;
  arduinoPort.write(cmd, (err) => {
    if (err) {
      console.error("❌ Error writing to Arduino:", err);
      return res.status(500).json({ error: "Failed to send SMS" });
    }
    console.log("📤 Sent to Arduino:", cmd.trim());
    res.json({ status: "SMS request sent to Arduino" });
  });
});

app.listen(3000, () => console.log("✅ Node.js API running on http://localhost:3000"));
