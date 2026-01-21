# Fix: Terraform errors - container image and Key Vault RBAC

## Summary
Fixes critical Terraform deployment errors in CI/CD pipeline:
- ✅ Handle empty container_image variable gracefully
- ✅ Disable Key Vault RBAC role assignments (requires Owner/User Access Administrator permissions)
- ✅ Update workflow to conditionally pass container_image
- ✅ Fix Terraform formatting

## Changes

### Infrastructure (Terraform)
- **appservice.tf**: Added logic to handle empty container_image with fallback to ACR default
- **keyvault.tf**: Commented out role assignments that require elevated permissions
- **variables.tf**: Made container_image optional with default empty string

### CI/CD
- **terraform-apply.yml**: Updated to conditionally pass container_image only when available

## Problems Solved

### 1. Empty container_image error ❌ → ✅
**Before:**
```
Error: expected "site_config.0.application_stack.0.docker_image_name" to not be an empty string
Error: expected "site_config.0.application_stack.0.docker_registry_url" to have a host, got https://
```

**After:** Uses placeholder image `<acr-name>.azurecr.io/dotnetcrudwebapi:latest` when container_image is not provided.

### 2. Key Vault RBAC permission error ❌ → ✅
**Before:**
```
Error: AuthorizationFailed: The client does not have authorization to perform action 'Microsoft.Authorization/roleAssignments/write'
```

**After:** Commented out role assignments that require elevated permissions. SQL password is passed directly.

## Test Plan
- [x] Terraform fmt passes
- [x] Local validation successful
- [ ] CI/CD pipeline runs successfully after merge

## Notes
- The Service Principal used by GitHub Actions needs only **Contributor** role now
- SQL password is passed directly to App Service
- Key Vault secrets can be enabled later with proper Service Principal permissions
