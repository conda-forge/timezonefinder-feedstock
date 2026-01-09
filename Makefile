.PHONY: help install lint validate build rerender clean check-checklist

help:
	@echo "Available commands:"
	@echo "  make install        - Install required dependencies (rattler-build, conda-smithy)"
	@echo "  make lint           - Validate recipe syntax with rattler-build"
	@echo "  make validate       - Validation with dependency solving"
	@echo "  make build          - Build package locally with build-locally.py"
	@echo "  make rerender       - Regenerate CI configuration files"
	@echo "  make check-checklist - Verify PR checklist requirements"
	@echo "  make clean          - Clean build artifacts"

install:
	@echo "Installing required dependencies..."
	conda install -y rattler-build conda-smithy -c conda-forge

lint:
	@echo "Validating recipe with rattler-build..."
	@which rattler-build > /dev/null 2>&1 || { echo "Error: rattler-build not found in PATH. Run 'make install' first."; exit 1; }
	rattler-build build --recipe recipe/recipe.yaml --render-only

validate:
	@echo "Validating recipe with dependency solving..."
	@which rattler-build > /dev/null 2>&1 || { echo "Error: rattler-build not found in PATH. Run 'make install' first."; exit 1; }
	rattler-build build --recipe recipe/recipe.yaml --render-only --with-solve

build:
	@echo "Building package locally..."
	python build-locally.py

rerender:
	@echo "Rerendering feedstock CI configuration..."
	@echo "This regenerates .ci_support files and CI pipelines based on recipe changes."
	@which rattler-build > /dev/null 2>&1 || { echo "Error: rattler-build not found in PATH. Ensure conda bin is in PATH."; echo "Try: export PATH=\"$$(conda info --base)/bin:\$$PATH\""; exit 1; }
	@which conda-smithy > /dev/null 2>&1 || { echo "Error: conda-smithy not found. Run 'make install' first."; exit 1; }
	conda smithy rerender -c auto

check-checklist:
	@echo "Checking PR checklist requirements..."
	@echo ""
	@echo "1. Fork Status:"
	@if git remote get-url origin | grep -q "conda-forge/timezonefinder-feedstock"; then \
		echo "   ⚠️  Working on main conda-forge repository"; \
		echo "   ℹ️  You should fork and work on your personal fork"; \
	else \
		echo "   ✅ Working on a fork"; \
	fi
	@echo ""
	@echo "2. Build Number:"
	@VERSION=$$(awk '/^context:/,/^package:/ {if (/version:/) {gsub(/[" ]/, ""); sub(/.*version:/, ""); print; exit}}' recipe/recipe.yaml); \
	BUILD_NUM=$$(awk '/^build:/,/^requirements:/ {if (/number:/) {sub(/.*number:/, ""); gsub(/ /, ""); print; exit}}' recipe/recipe.yaml); \
	echo "   Version: $$VERSION"; \
	echo "   Build number: $$BUILD_NUM"; \
	if [ "$$BUILD_NUM" = "0" ]; then \
		echo "   ✅ Build number is 0 (correct for new version)"; \
	else \
		echo "   ℹ️  Build number is $$BUILD_NUM (should be 0 for version bump, >0 for recipe-only changes)"; \
	fi
	@echo ""
	@echo "3. Re-render Status:"
	@if [ -d ".ci_support" ] && [ -n "$$(ls -A .ci_support/*.yaml 2>/dev/null | grep -v migrations)" ]; then \
		echo "   ✅ CI support files exist"; \
	elif [ ! -d ".ci_support" ]; then \
		echo "   ⚠️  .ci_support directory missing - run 'make rerender'"; \
	else \
		echo "   ℹ️  No platform-specific CI configs (all variants may be skipped)"; \
	fi
	@echo ""
	@echo "4. License File:"
	@if grep -q "license_file:" recipe/recipe.yaml; then \
		LICENSE_FILE=$$(grep "license_file:" recipe/recipe.yaml | sed 's/.*license_file: *\(.*\)/\1/'); \
		echo "   ✅ License file specified: $$LICENSE_FILE"; \
	else \
		echo "   ⚠️  No license_file specified in recipe.yaml"; \
	fi
	@echo ""
	@echo "See copilot-instructions.md for detailed contribution guidelines."

clean:
	@echo "Cleaning build artifacts..."
	rm -rf build_artifacts/
	rm -rf .build_artifacts/
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
