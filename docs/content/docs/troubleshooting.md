---
title: "Troubleshooting"
description: "Common issues and solutions for the Stock Watchlist API"
weight: 5
---

This guide covers common issues you may encounter while setting up and using the Stock Watchlist API.

## Authentication Issues

### "Invalid token" errors

**Symptoms:**
- Getting `401 Unauthorized` responses
- Error message: `"Invalid authentication credentials"`

**Solutions:**
- ✅ Make sure you're using the **ID token**, not the access token from Google
- ✅ Verify your `GOOGLE_CLIENT_ID` in `.env` matches the one in Google Cloud Console
- ✅ Check that the token hasn't expired (Google ID tokens expire after 1 hour)
- ✅ Ensure the Authorization header format is correct: `Bearer YOUR_ID_TOKEN`

**How to get a fresh token:**
1. Go to [Google OAuth 2.0 Playground](https://developers.google.com/oauthplayground/)
2. Use your own OAuth credentials (Client ID/Secret)
3. Select `userinfo.email` and `userinfo.profile` scopes
4. Get a new ID token

### Token format issues

**Wrong:**
```bash
Authorization: YOUR_TOKEN
Authorization: Bearer: YOUR_TOKEN
```

**Correct:**
```bash
Authorization: Bearer YOUR_TOKEN
```

## Database Connection Issues

### MySQL connection problems

**Symptoms:**
- API can't connect to database
- Error messages about connection refused

**Solutions:**
- ✅ Check MySQL container is healthy: `docker-compose ps`
- ✅ Verify database credentials in `.env` file match `docker-compose.yml`
- ✅ Ensure MySQL container has fully started (can take 30-60 seconds)
- ✅ Check MySQL logs: `docker-compose logs mysql`

**Check MySQL health:**
```bash
# View container status
docker-compose ps

# Check MySQL logs
docker-compose logs mysql

# Test MySQL connection
docker-compose exec mysql mysql -u stockuser -p stockwatchlist
```

### Database initialization issues

**Symptoms:**
- Tables don't exist
- Schema errors

**Solution:**
```bash
# Reset database completely
docker-compose down -v
docker-compose up -d
```

## Container Issues

### "Connection refused" or "ECONNRESET"

**Symptoms:**
- Can't reach the API at `localhost:8000`
- Connection timeouts

**Solutions:**
- ✅ Ensure containers are running: `docker-compose ps`
- ✅ Check if debugpy is waiting: `docker-compose logs fastapi`
- ✅ If `DEBUG=true`, either attach VS Code debugger or set `DEBUG=false`
- ✅ Restart containers: `docker-compose restart fastapi`

**Debug container status:**
```bash
# Check all containers
docker-compose ps

# View FastAPI logs
docker-compose logs fastapi

# Restart specific service
docker-compose restart fastapi
```

### Container won't start

**Symptoms:**
- Containers exit immediately
- Build failures

**Solutions:**
- ✅ Check logs: `docker-compose logs fastapi`
- ✅ Verify all environment variables in `.env` are set
- ✅ Try rebuilding: `docker-compose down && docker-compose up -d --build`
- ✅ Check Docker daemon is running
- ✅ Ensure sufficient disk space

**Complete rebuild:**
```bash
# Stop everything and rebuild
docker-compose down
docker-compose up -d --build

# If that fails, try a clean rebuild
docker-compose down -v
docker system prune -f
docker-compose up -d --build
```

### Permission issues with volumes

**Symptoms:**
- Files can't be read/written in containers
- Permission denied errors

**Solution:**
```bash
# Remove volumes and recreate
docker-compose down -v
docker-compose up -d
```

## Port Conflicts

### Ports 8000 or 3306 already in use

**Symptoms:**
- "Port already in use" errors
- Containers fail to start

**Check what's using the ports:**
```bash
# Check port 8000 (FastAPI)
lsof -i :8000

# Check port 3306 (MySQL)  
lsof -i :3306
```

**Solutions:**
1. **Stop conflicting services:**
   ```bash
   # Kill processes using the ports
   sudo kill -9 $(lsof -t -i:8000)
   sudo kill -9 $(lsof -t -i:3306)
   ```

2. **Or change ports in `docker-compose.yml`:**
   ```yaml
   # Change FastAPI to port 8001
   ports:
     - "8001:8000"
   
   # Change MySQL to port 3307
   ports:  
     - "3307:3306"
   ```

## VS Code Debugging Issues

### "Debugger not connecting"

**Symptoms:**
- VS Code can't connect to debugger
- Debugging session fails to start

**Solutions:**
- ✅ Check `DEBUG=true` in `.env` file
- ✅ Verify containers are running: `docker-compose ps`
- ✅ Check debugpy is waiting: `docker-compose logs fastapi`
- ✅ Ensure port 5678 is available locally: `lsof -i :5678`
- ✅ Try restarting containers: `docker-compose restart fastapi`

### "Breakpoints not hitting"

**Symptoms:**
- Breakpoints show as unbound
- Code doesn't pause at breakpoints

**Solutions:**
- ✅ Verify path mapping in `.vscode/launch.json`
- ✅ Check file paths match between local and container: `./app:/app`
- ✅ Ensure you're using "Debug FastAPI in Docker" configuration
- ✅ Make sure you're setting breakpoints in the actual code being executed

### "Code changes not reloading"

**Symptoms:**
- Changes to code don't take effect
- Need to restart containers manually

**Solutions:**
- ✅ Confirm `DEBUG=true` enables `--reload` flag
- ✅ Check volume mapping in `docker-compose.yml`: `./app:/app`
- ✅ Restart containers if needed: `docker-compose restart fastapi`
- ✅ Verify file changes are being saved

## API Testing Issues

### Swagger UI authentication

**Problem:** Can't test authenticated endpoints in Swagger UI

**Solution:**
1. Click "Authorize" button in Swagger UI
2. Enter: `Bearer YOUR_GOOGLE_ID_TOKEN` (include "Bearer " prefix)
3. Click "Authorize"
4. Now you can test protected endpoints

### curl authentication issues

**Problem:** curl requests return authentication errors

**Check your curl syntax:**
```bash
# Correct format
curl -X GET "http://localhost:8000/me" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Common mistakes to avoid
curl -X GET "http://localhost:8000/me" \
  -H "Authorization: YOUR_TOKEN"  # Missing "Bearer"

curl -X GET "http://localhost:8000/me" \
  -H "Authorization: Bearer: YOUR_TOKEN"  # Extra colon
```

## Google OAuth Setup Issues

### "This app isn't verified" warning

**Symptoms:**
- Google shows security warning during OAuth flow

**Solutions:**
- ✅ This is normal for apps in testing mode
- ✅ Click "Advanced" → "Go to [app name] (unsafe)" to proceed  
- ✅ For production, verify your app with Google (optional)

### OAuth consent screen errors

**Symptoms:**
- Can't complete OAuth flow
- Scope or permission errors

**Solutions:**
- ✅ Verify OAuth consent screen is configured in Google Cloud Console
- ✅ Add your email to "Test users" section
- ✅ Ensure scopes include: `openid`, `email`, `profile`

### Redirect URI mismatch

**Symptoms:**
- "redirect_uri_mismatch" error during OAuth flow

**Solutions:**
- ✅ Add correct redirect URIs in Google Cloud Console:
  - `https://developers.google.com/oauthplayground` (for OAuth Playground)
  - `https://oauth.pstmn.io/v1/callback` (for Postman/Bruno)

## Environment Setup Issues

### Missing `.env` file

**Symptoms:**
- Environment variables not found
- Default values being used

**Solution:**
Create `.env` file in project root:
```bash
# Copy template
cp .env.example .env

# Or create manually with required variables
cat > .env << EOF
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=stockwatchlist
MYSQL_USER=stockuser
MYSQL_PASSWORD=stockpass
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
DATABASE_URL=mysql+pymysql://stockuser:stockpass@mysql:3306/stockwatchlist
DEBUG=false
EOF
```

### Invalid environment variables

**Symptoms:**
- Configuration errors
- Services can't start

**Check your `.env` file format:**
- ✅ No spaces around `=` sign
- ✅ No quotes around values (unless needed)
- ✅ No trailing spaces
- ✅ Valid Google Client ID format: `*.apps.googleusercontent.com`

## Performance Issues

### Slow API responses

**Symptoms:**
- Long response times
- Timeouts

**Solutions:**
- ✅ Check container resources: `docker stats`
- ✅ Verify MySQL performance: `docker-compose logs mysql`
- ✅ Monitor container CPU/memory usage
- ✅ Ensure adequate system resources

### High memory usage

**Solutions:**
```bash
# Check container memory usage
docker stats

# Restart containers to free memory
docker-compose restart

# Clean up unused Docker resources
docker system prune -f
```

## Development Workflow Issues

### Git and deployment

**Problem:** Changes not reflected after deployment

**Solutions:**
- ✅ Ensure changes are committed: `git status`
- ✅ Push to remote: `git push origin main`
- ✅ Check GitHub Actions: repository → Actions tab
- ✅ Verify GitHub Pages is enabled with "GitHub Actions" source

### Hugo documentation issues

**Problem:** Documentation not building or displaying correctly

**Solutions:**
```bash
# Test Hugo build locally
./docs/hugo-dev.sh build

# Serve locally to test
./docs/hugo-dev.sh serve

# Check for Hugo syntax errors in markdown files
```

## Getting Help

### Diagnostic Commands

Run these commands to gather diagnostic information:

```bash
# System status
docker --version
docker-compose --version

# Container status  
docker-compose ps
docker-compose logs

# Resource usage
docker stats

# Network status
docker network ls
docker-compose exec fastapi ping mysql

# Environment check
cat .env | grep -v PASSWORD | grep -v SECRET
```

### Log Collection

```bash
# Collect all logs
docker-compose logs > debug-logs.txt

# Specific service logs
docker-compose logs fastapi > fastapi-logs.txt
docker-compose logs mysql > mysql-logs.txt
```

### Clean Slate Reset

If all else fails, start completely fresh:

```bash
# Nuclear option - removes everything
./cleanup.sh --all

# Or manually
docker-compose down -v
docker system prune -af
rm -rf .env

# Then start over
./setup.sh
```

## Still Need Help?

If you're still having issues:

1. **Check the logs** using the diagnostic commands above
2. **Try a clean reset** with the nuclear option
3. **Review the [Quick Start Guide](../quick-start/)** for setup steps
4. **Check [OAuth Setup](../oauth-setup/)** for authentication issues  
5. **Consult [Testing Guide](../testing/)** for API testing problems

**For debugging:** Enable detailed logging by setting `DEBUG=true` in your `.env` file and checking container logs.