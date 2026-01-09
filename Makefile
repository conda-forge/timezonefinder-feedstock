.PHONY: help install lint validate build rerender clean

help:
	@echo "Available commands:"
	@echo "  make install   - Install required dependencies (rattler-build, conda-smithy)"
	@echo "  make lint      - Validate recipe syntax with rattler-build"
	@echo "  make validate  - Validation with dependency solving"
	@echo "  make build     - Build package locally with build-locally.py"
	@echo "  make rerender  - Regenerate CI configuration files"
	@echo "  make clean     - Clean build artifacts"

install:
	@echo "Installing required dependencies..."
	conda install -y rattler-build conda-smithy -c conda-forge

lint:
	@echo "Validating recipe with rattler-build..."
	rattler-build build --recipe recipe/recipe.yaml --render-only

validate:
	@echo "Validating recipe with dependency solving..."
	rattler-build build --recipe recipe/recipe.yaml --render-only --with-solve

build:
	@echo "Building package locally..."
	python build-locally.py

rerender:
	@echo "Rerendering feedstock CI configuration..."
	@echo "This regenerates .ci_support files and CI pipelines based on recipe changes."
	conda smithy rerender -c auto

clean:
	@echo "Cleaning build artifacts..."
	rm -rf build_artifacts/
	rm -rf .build_artifacts/
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
