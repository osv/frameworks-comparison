const browserSync = require('browser-sync'),
      url = require('url'),
      proxy = require('proxy-middleware');

const proxyOptions = url.parse(process.env.PROXY || 'http://localhost:3000/projects/api-tree');
proxyOptions.route = '/projects/api-tree';

browserSync({
  open: true,
  port: 8080,
  files: './src/',
  server: {
    baseDir: "./src",
    middleware: [proxy(proxyOptions)]
  }
});
