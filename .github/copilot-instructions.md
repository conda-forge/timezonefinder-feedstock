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
- Increment build number when changing recipe without version bump
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

### Version Updates
1. Update version in context section
2. Update source URL and SHA256 hash
3. Check if dependency versions need updating
4. Reset build number to 0 for new versions
5. Test locally with `python build-locally.py`
6. Submit PR and verify CI passes

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
- Test locally using `python build-locally.py` before pushing
- Consider platform-specific conditionals if needed
- Run local linting with `conda smithy recipe-lint recipe/` to catch issues before CI

### Dropping Python Version Support
When dropping support for older Python versions (e.g., 3.9, 3.10):
1. **Add skip condition in recipe.yaml**: Add to build section:
   ```yaml
   skip:
     - py<311
   ```
2. **Do NOT add version constraints to python in requirements**: Non-noarch packages must have `python` without version constraints in host/run sections (causes linting errors)
3. **Do NOT use python_min in conda-forge.yml**: This property is not supported and will cause linting errors
4. **Update dependencies**: Check if any dependencies (like NumPy) also require Python version updates
5. The `skip: py<311` condition ensures builds only happen for supported Python versions

### Updating NumPy Requirements
When updating NumPy version constraints (e.g., following NumPy's deprecation policy):
- Update the constraint in the run section of requirements
- Example: Change `numpy >=1.23,<3` to `numpy >=2,<3` when requiring NumPy 2+
- Coordinate with Python version requirements, as NumPy 2+ may drop older Python versions

### Bot Integration
- Bot inspection uses `hint-grayskull` for automatic updates
- Bot will create PRs for version updates automatically
- Review bot PRs carefully, especially dependency changes

## Anti-Patterns to Avoid
- ❌ Don't use old conda-build syntax (`{{ variable }}`) - use rattler-build syntax (`${{ variable }}`)
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
