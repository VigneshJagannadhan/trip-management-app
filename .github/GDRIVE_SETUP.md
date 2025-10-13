# Google Drive Upload Setup Guide

## Step 1: Get Your Service Account JSON

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create/select your project
3. Enable Google Drive API
4. Create a Service Account
5. Download the JSON key file

## Step 2: Convert JSON to Base64

### On macOS/Linux:
```bash
# Navigate to where you downloaded the JSON file
cd ~/Downloads

# Convert to base64 (single line, no wrapping)
base64 -i your-service-account.json | tr -d '\n' > credentials_base64.txt

# View the base64 string
cat credentials_base64.txt
```

### On Windows (PowerShell):
```powershell
# Navigate to where you downloaded the JSON file
cd $HOME\Downloads

# Convert to base64
[Convert]::ToBase64String([System.IO.File]::ReadAllBytes("your-service-account.json")) | Out-File -Encoding ASCII credentials_base64.txt

# View the base64 string
Get-Content credentials_base64.txt
```

### Online Tool (if needed):
You can also use: https://www.base64encode.org/
- Paste your entire JSON content
- Click "Encode"
- Copy the result

## Step 3: Add to GitHub Secrets

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add these secrets:

### Required Secrets:

#### `GDRIVE_CREDENTIALS_BASE64`
- **Value**: The base64 string from Step 2
- **Format**: Single line, no line breaks
- **Example**: `ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAgInByb2plY3RfaWQiOi...`

#### `GDRIVE_FOLDER_ID`
- **Value**: Your Google Drive folder ID
- **How to get**:
  1. Open Google Drive
  2. Navigate to your target folder
  3. Look at the URL: `https://drive.google.com/drive/folders/FOLDER_ID_HERE`
  4. Copy the `FOLDER_ID_HERE` part
- **Example**: `1a2b3c4d5e6f7g8h9i0j`

#### `SUPABASE_URL`
- **Value**: Your Supabase project URL
- **Example**: `https://xxxxxxxxxxxxx.supabase.co`

#### `SUPABASE_ANON_KEY`
- **Value**: Your Supabase anonymous key
- **Example**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## Step 4: Share Folder with Service Account

**IMPORTANT**: The service account needs access to your Google Drive folder!

1. Open Google Drive
2. Right-click on your target folder
3. Click "Share"
4. Add the service account email (found in your JSON file: `client_email`)
5. Give it "Editor" permissions
6. Click "Send"

Example service account email:
```
your-service-account@your-project.iam.gserviceaccount.com
```

## Step 5: Test the Workflow

1. Commit and push your changes
2. Go to GitHub → Actions tab
3. Watch the workflow run
4. Check your Google Drive folder for the uploaded APK

## Troubleshooting

### "base64 decoding failed"
- ✅ **Solution**: Make sure you created `GDRIVE_CREDENTIALS_BASE64` (not `GDRIVE_CREDENTIALS`)
- Verify the base64 string has no line breaks
- Re-encode the JSON and try again

### "403 Forbidden" or "Permission denied"
- ✅ **Solution**: Share the Google Drive folder with the service account email
- Make sure the service account has "Editor" permissions
- Wait a few minutes for permissions to propagate

### "File not found"
- ✅ **Solution**: This is now fixed - the workflow builds a universal APK
- Check that the build step completed successfully

### "Invalid credentials"
- ✅ **Solution**: Re-download the service account JSON
- Make sure you're encoding the entire JSON content
- Verify no extra characters were added

## Verification Checklist

- [ ] Service account created in Google Cloud Console
- [ ] Google Drive API enabled
- [ ] JSON key downloaded
- [ ] JSON converted to base64 (single line)
- [ ] `GDRIVE_CREDENTIALS_BASE64` secret added to GitHub
- [ ] `GDRIVE_FOLDER_ID` secret added to GitHub
- [ ] `SUPABASE_URL` secret added to GitHub
- [ ] `SUPABASE_ANON_KEY` secret added to GitHub
- [ ] Google Drive folder shared with service account email
- [ ] Service account has "Editor" permissions on folder
- [ ] Workflow triggered and running

## Expected Result

After a successful build:
- ✅ Split APKs available in GitHub Actions artifacts
- ✅ Universal APK available in GitHub Actions artifacts
- ✅ Universal APK uploaded to your Google Drive folder
- ✅ File named: `trippify-{commit-sha}.apk`

## Need Help?

If you encounter issues:
1. Check the Actions log for detailed error messages
2. Verify all secrets are correctly set
3. Ensure the service account has proper permissions
4. Try re-creating the service account if needed

