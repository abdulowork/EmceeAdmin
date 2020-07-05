open: 
	open Package.swift

app: 
	swift build
	rm -rf .build/app/
	mkdir -p .build/app/EmceeAdmin.app/Contents/MacOS/
	cp .build/debug/emceeadmin .build/app/EmceeAdmin.app/Contents/MacOS/
	open .build/app
	
