# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Conventions definitions
#

# Synopsis: Flags warnings for deprecated options.
Export-PSRuleConvention 'Azure.DeprecatedOptions' -Initialize {
    $aksMinimumVersion = $Configuration.GetValueOrDefault('Azure_AKSMinimumVersion', $Null);
    if ($Null -ne $aksMinimumVersion) {
        Write-Warning -Message $LocalizedData.AKSMinimumVersionReplace;
    }
}

# Synopsis: Expand Azure resources from parameter files.
Export-PSRuleConvention 'Azure.ExpandTemplate' -If { $Configuration.AZURE_PARAMETER_FILE_EXPANSION -eq $True -and $TargetObject.Extension -eq '.json' -and $Assert.HasJsonSchema($PSRule.GetContentFirstOrDefault($TargetObject), @(
    "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json`#"
    "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json`#"
), $True) } -Begin {
    Write-Verbose "[Azure.ExpandTemplate] -- Expanding parameter file: $($TargetObject.FullName)";
    $timeout = $Configuration.GetIntegerOrDefault('AZURE_BICEP_FILE_EXPANSION_TIMEOUT', 5);
    try {
        $data = [PSRule.Rules.Azure.Runtime.Helper]::GetResources($TargetObject.FullName, $timeout);
        if ($Null -ne $data) {
            $PSRule.Import($data);
        }
    }
    catch [PSRule.Rules.Azure.Data.Template.TemplateException] {
        Write-Error -Exception $_.Exception;
    }
    catch [PSRule.Rules.Azure.Pipeline.TemplateReadException] {
        Write-Error -Exception $_.Exception;
    }
    catch [System.IO.FileNotFoundException] {
        Write-Error -Exception $_.Exception;
    }
    catch {
        Write-Error -Message "Failed to expand parameter file '$($TargetObject.FullName)'. $($_.Exception.Message)" -ErrorId 'Azure.ExpandTemplate.ConventionException';
    }
}

#region Bicep

# Synopsis: Install Bicep for expansion of .bicep files within GitHub Actions.
Export-PSRuleConvention 'Azure.BicepInstall' -If { $Configuration.AZURE_BICEP_FILE_EXPANSION -eq $True -and $Env:GITHUB_ACTION -eq '__Microsoft_ps-rule' } -Initialize {

    # Skip if already installed
    if (Test-Path -Path '/usr/local/bin/bicep') {
        return
    }

    # Install the latest Bicep CLI binary for alpine
    Invoke-WebRequest -Uri 'https://github.com/Azure/bicep/releases/latest/download/bicep-linux-musl-x64' -OutFile $Env:GITHUB_WORKSPACE/bicep.bin

    # Set executable
    chmod +x $Env:GITHUB_WORKSPACE/bicep.bin

    # Copy to PATH environment
    Move-Item $Env:GITHUB_WORKSPACE/bicep.bin /usr/local/bin/bicep
}

Export-PSRuleConvention 'Azure.ExpandBicep' -If { $Configuration.AZURE_BICEP_FILE_EXPANSION -eq $True -and $TargetObject.Extension -eq '.bicep' } -Begin {
    Write-Verbose "[Azure.ExpandBicep] -- Start expanding bicep source: $($TargetObject.FullName)";
    try {
        $timeout = $Configuration.GetIntegerOrDefault('AZURE_BICEP_FILE_EXPANSION_TIMEOUT', 5);
        $data = [PSRule.Rules.Azure.Runtime.Helper]::GetBicepResources($TargetObject.FullName, $PSCmdlet, $timeout);
        if ($Null -ne $data) {
            Write-Verbose "[Azure.ExpandBicep] -- Importing $($data.Length) Bicep resources.";
            $PSRule.Import($data);
        }
    }
    catch [PSRule.Rules.Azure.Pipeline.BicepCompileException] {
        Write-Error -Exception $_.Exception -ErrorId 'Azure.ExpandBicep.BicepCompileException';
    }
    catch [System.IO.FileNotFoundException] {
        Write-Error -Exception $_.Exception;
    }
    catch {
        Write-Error -Message "Failed to expand bicep source '$($TargetObject.FullName)'. $($_.Exception.Message)" -ErrorId 'Azure.ExpandBicep.ConventionException';
    }
    Write-Verbose "[Azure.ExpandBicep] -- Complete expanding bicep source: $($TargetObject.FullName)";
}

#endregion Bicep
