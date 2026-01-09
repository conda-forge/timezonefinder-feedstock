# GitHub Copilot Instructions for timezonefinder-feedstock

## Repository Purpose
This is a **conda-forge feedstock** for the `timezonefinder` Python library. A feedstock is a repository that contains the recipe and configuration files needed to build and maintain a conda package on conda-forge.

## Key Concepts

### What is timezonefinder?
A fast and lightweight Python package for looking up the timezone for given coordinates (lat/lng) on Earth, entirely offline. It uses numpy, h3-py, cffi, and python-flatbuffers.

### Repository Structure
- **recipe/recipe.yaml**: The main recipe file defining package metadata, dependencies, build instructions, and tests
- **conda-forge.yml**: Configuration for conda-forge infrastructure (build platforms, bot settings, tooling)
- **azure-pipelines.yml**: CI/CD configuration for Azure Pipelines
- **build-locally.py**: Script for local testing of the feedstock
- **pixi.toml**: Pixi project configuration (conda_install_tool)

## Coding Standards & Guidelines

### Recipe Files (recipe.yaml)
- Use **schema_version: 1** format (rattler-build style, not conda-build)
- Use Jinja2 templating with `${{ variable }}` syntax (not `{{ variable }}` from old conda-build)
- Structure sections in order: context, package, source, build, requirements, tests, about, extra
- Version in context section should be a string in quotes: `version: "8.2.1"`
- Always verify SHA256 checksums for source URLs
- Use conditional dependencies with `if/then` blocks for cross-compilation

### Requirements Management
- Separate requirements into: `build`, `host`, and `run` sections
- Build section: compilers and cross-compilation tools
- Host section: build-time Python dependencies
- Run section: runtime dependencies with version constraints
- Pin versions appropriately: use `>=X.Y,<Z` for compatibility ranges
- Include `${{ stdlib("c") }}` for C standard library

### Build Configuration
- Use `rattler-build` as the build tool (specified in conda-forge.yml)
- Use `pixi` as the install tool
- Build script: `${{ PYTHON }} -m pip install . -vv --no-deps --no-build-isolation`
- Increment build number when changing recipe without version bump (ensures unique package identification)
- Reset build number to 0 when incrementing version
- Support multiple Python versions and platforms (linux_64, osx_64, win_64, aarch64, ppc64le)

### Testing
- Always include import tests in the `tests` section
- Enable `pip_check: true` to verify dependencies
- Use native_and_emulated testing (from conda-forge.yml)

### Platform Support
- Configure cross-compilation for ARM and PowerPC architectures
- Use build_platform mappings in conda-forge.yml:
  - linux_aarch64 → linux_64
  - linux_ppc64le → linux_64
  - osx_arm64 → osx_64

## Maintenance Guidelines

### Prerequisites
Before working with this feedstock, ensure:
- `rattler-build` and `conda-smithy` are installed: `conda install rattler-build conda-smithy -c conda-forge`
- Conda bin directory is in your PATH: `export PATH="$(conda info --base)/bin:$PATH"`
- If `rattler-build` is not found during rerendering, the PATH may need to be updated

### Contributing to the Feedstock
To improve the recipe or build a new package version:

1. **Fork this repository** and create a branch in your fork
2. **Submit a PR** from your fork's branch (not from main repository branches)
3. Upon submission, changes are automatically built on all platforms for review
4. Once merged, the recipe is re-built and uploaded to conda-forge channel
5. **Important**: All branches in conda-forge/timezonefinder-feedstock are immediately built and uploaded, so always use branches in forks for PRs

**Build number management** (critical for package identification):
- **Version unchanged**: Increment `build: number` in recipe.yaml
- **Version increased**: Reset `build: number` to 0

### Version Updates
1. Update version in context section
2. Update source URL and SHA256 hash
3. Check if dependency versions need updating
4. Reset build number to 0 for new versions
5. Validate with `make lint` to check syntax
6. If skip conditions or dependencies changed, run `make rerender`
7. Test locally with `make build` or `python build-locally.py`
8. Verify checklist with `make check-checklist`
9. Submit PR from your fork and verify CI passes

### PR Checklist Validation
Before submitting a PR, verify all requirements with:

```bash
make check-checklist
```

This validates:
- **Fork status**: Confirms you're working on a personal fork (not the main repository)
- **Build number**: Verifies build number is appropriate (0 for version bumps, incremented for recipe-only changes)
- **Re-render status**: Checks if CI configuration files are properly generated
- **License file**: Confirms license_file is specified in recipe.yaml

**Important**: All branches in the main conda-forge repository are automatically built and published. Always work in a fork and submit PRs from your fork to avoid unintended builds.

### Recipe Maintainers
Current maintainers (from extra section): xylar, snowman2, jannikmi
- Tag maintainers in PRs that need review
- Follow conda-forge guidelines for maintainer updates

### Dependencies to Monitor
- numpy (currently >=2,<3)
- h3-py (currently >4)
- cffi (currently >=1.15.1,<3)
- python-flatbuffers (currently >=25.2.10)
- setuptools (currently >=61)

## Common Tasks

### Adding a New Dependency
Add to appropriate section (host for build-time, run for runtime) with version constraints

### Updating Compiler Requirements
Use `${{ compiler('c') }}` syntax for C compilers, ensure stdlib is included

### Fixing Build Issues
- Check Azure Pipelines logs for specific platform failures
- Test locally using `make build` or `python build-locally.py` before pushing
- Validate recipe syntax with `make lint` before committing changes
- Consider platform-specific conditionals if needed
- Run local recipe validation with rattler-build: `/path/to/rattler-build build --recipe recipe/recipe.yaml --render-only`
- Note: `conda smithy recipe-lint` doesn't fully support rattler-build's `schema_version: 1` format yet; use rattler-build for validation or rely on CI linting

### Dropping Python Version Support
When dropping support for older Python versions (e.g., 3.9, 3.10):
1. **Add skip condition in recipe.yaml**: Add to build section using the `match()` function:
   ```yaml
   skip:
     - match(python, '<3.11')
   ```
   **Important**: For rattler-build recipes (schema_version: 1), use `match(python, '<3.11')` instead of `py<311`. The `py<311` syntax is conda-build specific and will cause all variants to be skipped in rattler-build, resulting in no CI configs being generated.
   
   The `match()` function is the rattler-build way to do version comparisons. Other examples:
   - `match(python, '>=3.8')` - matches Python 3.8 and above
   - `match(python, '>=3.8,<3.12')` - matches Python 3.8-3.11
   
2. **Do NOT add version constraints to python in requirements**: Non-noarch packages must have `python` without version constraints in host/run sections (causes linting errors)
3. **Do NOT use python_min in conda-forge.yml**: This property is not supported and will cause linting errors
4. **Update dependencies**: Check if any dependencies (like NumPy) also require Python version updates
5. **Rerender the feedstock**: Run `make rerender` to regenerate CI configurations and remove builds for dropped Python versions
6. **Commit and push**: The rerender creates a commit that needs to be pushed to apply changes
7. The skip condition with `match(python, '<3.11')` ensures builds only happen for Python 3.11+

### Updating NumPy Requirements
When updating NumPy version constraints (e.g., following NumPy's deprecation policy):
- Update the constraint in the run section of requirements
- Example: Change `numpy >=1.23,<3` to `numpy >=2,<3` when requiring NumPy 2+
- Coordinate with Python version requirements, as NumPy 2+ may drop older Python versions

### Rerendering the Feedstock
After making recipe changes that affect build variants (Python versions, skip conditions, dependencies), you must rerender:

```bash
make rerender
# or manually:
conda smithy rerender -c auto
```

**When to rerender:**
- After adding/modifying skip conditions
- After changing Python version support
- After updating dependencies that affect build matrix
- After modifying conda-forge.yml configuration

**What rerendering does:**
- Regenerates `.ci_support/*.yaml` files with correct build variants
- Updates CI pipeline configurations (Azure Pipelines, etc.)
- Applies conda-forge migrations
- Removes CI configs for skipped variants (e.g., Python 3.10 after adding `skip: match(python, '<3.11')`)

**Troubleshooting:**
- If `rattler-build` is not found, ensure conda bin is in PATH: `export PATH="$(conda info --base)/bin:$PATH"`
- Rerendering requires both `rattler-build` and `conda-smithy` to be installed and in PATH
- After rerendering, commit and push the changes
- If no CI configs are generated, check that skip conditions use correct rattler-build syntax (e.g., `match(python, '<3.11')` not `py<311`)

### Bot Integration
- Bot inspection uses `hint-grayskull` for automatic updates
- Bot will create PRs for version updates automatically
- Review bot PRs carefully, especially dependency changes

## Anti-Patterns to Avoid
- ❌ Don't use old conda-build syntax (`{{ variable }}`) - use rattler-build syntax (`${{ variable }}`)
- ❌ Don't use conda-build skip syntax (`py<311`) in rattler-build recipes - use `match(python, '<3.11')` instead
- ❌ Don't forget to update SHA256 when changing versions
- ❌ Don't pin dependencies too strictly unless necessary
- ❌ Don't skip cross-compilation configuration for ARM/PowerPC
- ❌ Don't forget to increment build number for recipe-only changes
- ❌ Don't bypass pip_check without good reason
- ❌ Don't add Python version constraints directly in host/run requirements for non-noarch packages (use skip conditions instead)
- ❌ Don't use `python_min` in conda-forge.yml (not a valid property)

## External Resources
- Upstream repository: https://github.com/jannikmi/timezonefinder
- Package GUI: https://timezonefinder.michelfe.it/gui
- conda-forge documentation: https://conda-forge.org/docs/
- rattler-build docs: https://prefix-dev.github.io/rattler-build/

## Local Development Tools

### Quick Commands (Makefile)
The repository includes a Makefile with convenient commands:

```bash
make help            # Show all available commands
make install         # Install required dependencies
make lint            # Quick syntax validation
make validate        # Validation with dependency solving
make build           # Build package locally
make rerender        # Regenerate CI configuration files
make check-checklist # Verify PR checklist requirements
make clean           # Clean build artifacts
```

### Validating Recipes (schema_version: 1)
For rattler-build recipes (schema_version: 1), use `rattler-build` for validation:

```bash
# Install rattler-build via conda
conda install rattler-build -c conda-forge

# Validate recipe syntax by rendering only
rattler-build build --recipe recipe/recipe.yaml --render-only

# Full local build test
rattler-build build --recipe recipe/recipe.yaml
```

**Note:** The traditional `conda smithy recipe-lint` tool doesn't fully support rattler-build's `schema_version: 1` format yet. It will report false errors about `schema_version` being unexpected. The CI linting on conda-forge has been updated to support rattler-build recipes and will provide accurate validation.
