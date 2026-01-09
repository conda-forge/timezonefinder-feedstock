.PHONY: help install lint validate build clean

help:
	@echo "Available commands:"
	@echo "  make install   - Install required dependencies (rattler-build)"
	@echo "  make lint      - Validate recipe syntax with rattler-build"
	@echo "  make validate  - Full validation with dependency solving"
	@echo "  make build     - Build package locally with build-locally.py"
	@echo "  make clean     - Clean build artifacts"

install:
	@echo "Installing required dependencies..."
	conda install -y rattler-build -c conda-forge

lint:
	@echo "Validating recipe with rattler-build..."
	rattler-build build --recipe recipe/recipe.yaml --render-only

validate:
	@echo "Validating recipe with dependency solving..."
	rattler-build build --recipe recipe/recipe.yaml --render-only --with-solve

build:
	@echo "Building package locally..."
	python build-locally.py

clean:
	@echo "Cleaning build artifacts..."
	rm -rf build_artifacts/
	rm -rf .build_artifacts/
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
