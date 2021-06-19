#!/usr/bin/env bash
git clone https://github.com/eh3rrera/react-app-frontend.git
echo "export default "\"$*\"";">react-app-frontend/src/api/serverUrl.js
cd react-app-frontend
npm install
npm run build 