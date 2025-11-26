const express = require("express");
const { createProxyMiddleware } = require("http-proxy-middleware");

const app = express();

app.use("/", createProxyMiddleware({
  target: "https://maqplan.sprinthub.app",
  changeOrigin: true,
  selfHandleResponse: false,
  onProxyReq: (proxyReq, req, res) => {
    console.log("➡️", req.method, req.url);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log("⬅️", proxyRes.statusCode);
  }
}));

app.listen(3000, () => console.log("Proxy ouvindo em http://localhost:3000"));
