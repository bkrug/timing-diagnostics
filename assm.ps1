# Run this script with XAS99 to assemble all files
# See https://endlos99.github.io/xdt99/
#
# If you can't run powershell scripts research this command locally:
# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

write-host 'Creating Cartridge'

$fileList = `
    'VAR', 'MAIN', 'DISPLAY', 'GROM', 'VDP', 'CART'

#Deleting old work files
write-host 'Deleting old work files'
ForEach($file in $fileList) {
    $objFile = $file + '.obj'
    $lstfile = $file + '.lst'
    if (Test-Path $objFile) { Remove-Item $objFile }
    if (Test-Path $lstFile) { Remove-Item $lstFile }
}

#Assembling files
write-host 'Assembling source code'
ForEach($file in $fileList) {
    $asmFile = $file + '.asm'
    $lstFile = $file + '.lst'
    write-host '    ' $asmFile
    xas99.py $asmFile -S -R -L $lstFile
}

#Exit if assembly errors found
ForEach($file in $fileList) {
    $objFile = $file + '.obj'
    if (-not(Test-Path $objFile)) {
        $msg = $file + ' did not assemble correctly'
        write-host $msg -ForegroundColor Red
        exit
    }
}

#Link object files into cartridge
write-host 'Creating cartridge'
$outputCartridgeFile = 'timeDiagnostic.C.bin'
xas99.py -b -a ">6000" -o $outputCartridgeFile -l `
    CART.obj `
    MAIN.obj `
    DISPLAY.obj `
    GROM.obj `
    VDP.obj `
    VAR.obj

#Create .rpk file for MAME
$zipFileName = ".\TimeDiagnostic.zip"
$rpkFileName = ".\TimeDiagnostic.rpk"
compress-archive -Path ".\layout.xml",$outputCartridgeFile $zipFileName -compressionlevel optimal
if (Test-Path $rpkFileName) { Remove-Item $rpkFileName }
Rename-Item $zipFileName $rpkFileName

#Link object files into E/A option 5 program
write-host 'Creating E/A option 5 program'
$outputEA5program = 'timeDiagnostic.program'
xas99.py -i -o $outputEA5program -l `
    MAIN.obj `
    DISPLAY.obj `
    GROM.obj `
    VDP.obj `
    VAR.obj

#Create disk image
write-host 'Creating disk image'
$diskImage = 'timeDiagnostic.dsk'
xdm99.py -X sssd $diskImage
xdm99.py $diskImage -a $outputEA5program -f PROGRAM

#Delete work files
write-host 'Deleting work files'
ForEach($file in $fileList) {
    $objFile = $file + '.obj'
    $lstfile = $file + '.lst'
    Remove-Item $objFile
    Remove-Item $lstFile
}
Remove-Item $outputEA5program