param(
    [string]$productName = "terraform",
    [string]$os = "linux",
    [string]$arch = "amd64",
    [string]$version = "latest"
)

Function Get-Products {
    Invoke-RestMethod -Uri https://api.releases.hashicorp.com/v1/products | Format-Table
}

Function Get-ProductVersionDownloadUrl {
    param(
        [string]$productName = "waypoint",
        [string]$os = "linux",
        [string]$arch = "amd64",
        [string]$version = "latest"
    )

    $url = "--"

    $products = Invoke-RestMethod -Uri https://api.releases.hashicorp.com/v1/releases/$productName
    $products = $products | Sort-Object -Property version | Select-Object -First 1
    $products  | ForEach-Object {
        #$_ | Select-Object -ExcludeProperty builds | Format-List
        #Write-Host $_.version
        $_.builds | ForEach-Object {
            if($os -eq $_.os) {
                if($arch -eq $_.arch) {
                    Write-Host $_.url
                    $url = $_.url
                }
            }
        }
    }

    $url
}

Function Invoke-Install {
    param(
        [string]$productName = "waypoint",
        [string]$os = "linux",
        [string]$arch = "amd64",
        [string]$version = "latest"
    )

    $install_dir = "/home/$env:USER/.hashicorp";
    if($false -eq (Test-Path -Path $install_dir)) {
        New-Item -Type Directory -Path $install_dir
    } 

    $product_install_dir = "$install_dir/$productName";
    if($false -eq (Test-Path -Path $product_install_dir)) {
        New-Item -Type Directory -Path $product_install_dir
    } 

    $version_install_dir = "$product_install_dir/$version";
    if($false -eq (Test-Path -Path $version_install_dir)) {
        New-Item -Type Directory -Path $version_install_dir -Force
    } else {
        #Write-Host "Cleanup version install directory any previous files."
        Remove-Item -Path $version_install_dir -Force -Recurse 
        New-Item -Type Directory -Path $version_install_dir -Force
    }

    $url = Get-ProductVersionDownloadUrl -productName $productName -os $os -arch $arch -version $version
    $install_zip = "$version_install_dir/install.zip"

    if($false -eq (Test-Path -Path $install_zip)) {
        #Write-Host "Downloading..."
        Invoke-RestMethod -Uri $url -OutFile $install_zip 
    }
    
    #Write-Host "Expanding archive..." 
    Expand-Archive $install_zip -DestinationPath $version_install_dir -Force
    
    # Setup Alias
    #Write-Host "Setting up alias..."
    Set-Alias -Name $productName -Value "$version_install_dir/$productName"
    Invoke-Expression -Command "$version_install_dir/$productName"

    # Update Path 
    $env:PATH = ($env:PATH.Split(';') | Where-Object -FilterScript {$_ -notcontains $product_install_dir}) -join ':'
    $env:PATH = $env:PATH + ":" + $version_install_dir
    
    # update for real
    $machine_env = [System.Environment]::GetEnvironmentVariable("PATH").Split(":")
    $machine_env = ($machine_env.Split(':') | Where-Object -FilterScript {$_.StartsWith($product_install_dir) -eq $false}) -join ':'
    $machine_env = $machine_env + ":" + $version_install_dir
    [System.Environment]::SetEnvironmentVariable("PATH", $machine_env)
}

Invoke-Install -productName $productName -os $os -arch $arch -version $version
#Get-Products