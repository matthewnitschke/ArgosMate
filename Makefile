build:
	./build.sh

run-mocked:
	./build.sh
	./ArgosMate.app/Contents/MacOS/ArgosMate --mock

run:
	./build.sh
	./ArgosMate.app/Contents/MacOS/ArgosMate

run-app:
	./build.sh
	open ./ArgosMate.app