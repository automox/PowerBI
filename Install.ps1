#Requires -Version 3

<#
    .SYNOPSIS
    Queries the Automox API.
          
    .DESCRIPTION
    Heavily leverages the "Get-AutomoxAPIObject" function in order to query the Automox API. The function will be automatically imported for usage during script execution.
          
    .PARAMETER OrganizationID
    A valid Automox organization ID. This might take the form of a number or a GUID.

    .PARAMETER APIKey
    A valid Automox API key that is associated with the specified organization ID.

    .PARAMETER ExportDirectory
    A valid directory where the API request data will be exported. If the directory does not exist, it will be automatically created.

    .PARAMETER LogDirectory
    A valid directory where the script logs will be located. By default, "C:\Windows\Logs\Software\Get-AutomoxAPIData".

    .PARAMETER ContinueOnError
    Specifies whether to ignore fatal errors.

    .PARAMETER LogDir
    A valid folder path. If the folder does not exist, it will be created. This parameter can also be specified by the alias "LogPath".

    .PARAMETER ContinueOnError
    Ignore failures.
          
    .EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -NoProfile -NoLogo -File "FolderPathContainingScript\Get-AutomoxAPIData.ps1" -OrganizationID 'YourOrganizationID' -APIKey "YourAPIKey"

    .EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -NoProfile -NoLogo -File "FolderPathContainingScript\Get-AutomoxAPIData.ps1" -OrganizationID "YourOrganizationID" -APIKey "YourAPIKey" -ExecutionMode "Execute"
    
    .EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -NoProfile -NoLogo -File "FolderPathContainingScript\Get-AutomoxAPIData.ps1" -OrganizationID "YourOrganizationID" -APIKey "YourAPIKey" -ExecutionMode "CreateScheduledTask"
  
    .EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -NoProfile -NoLogo -File "FolderPathContainingScript\Get-AutomoxAPIData.ps1" -OrganizationID "YourOrganizationID" -APIKey "YourAPIKey" -ExecutionMode "RemoveScheduledTask"
    
    .NOTES
    Any useful tidbits
          
    .LINK
    A useful link
#>

[CmdletBinding(SupportsShouldProcess=$True)]
  Param
    (        	                 
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Alias('OID')]
        [System.String]$OrganizationID,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Alias('Key')]
        [System.String]$APIKey,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Alias('DD')]
        [System.IO.DirectoryInfo]$DownloadDirectory,
                              
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Alias('LogDir', 'LD')]
        [System.IO.DirectoryInfo]$LogDirectory,
            
        [Parameter(Mandatory=$False)]
        [Alias('COE')]
        [Switch]$ContinueOnError
    )
        
Function Test-ProcessElevationStatus
    {
        $Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $Principal = New-Object -TypeName 'System.Security.Principal.WindowsPrincipal' -ArgumentList ($Identity)
        $Result = $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

        Write-Output -InputObject ($Result)
    }

Switch (Test-ProcessElevationStatus)
  {
      Default
        {
            #Determine the date and time we executed the function
              $ScriptStartTime = (Get-Date)
  
            #Define Default Action Preferences
                $Script:DebugPreference = 'SilentlyContinue'
                $Script:ErrorActionPreference = 'Stop'
                $Script:VerbosePreference = 'SilentlyContinue'
                $Script:WarningPreference = 'Continue'
                $Script:ConfirmPreference = 'None'
                $Script:WhatIfPreference = $False
    
            #Load WMI Classes
              $OperatingSystem = Get-CIMInstance -Namespace "root\CIMv2" -ClassName "Win32_OperatingSystem" -Property *

            #Retrieve property values
              $OSArchitecture = $($OperatingSystem.OSArchitecture).Replace("-bit", "").Replace("32", "86").Insert(0,"x").ToUpper()

            #Define variable(s)
              $DateTimeLogFormat = 'dddd, MMMM dd, yyyy @ hh:mm:ss.FFF tt'  ###Monday, January 01, 2019 @ 10:15:34.000 AM###
              [ScriptBlock]$GetCurrentDateTimeLogFormat = {(Get-Date).ToString($DateTimeLogFormat)}
              $DateTimeMessageFormat = 'MM/dd/yyyy HH:mm:ss.FFF'  ###03/23/2022 11:12:48.347###
              [ScriptBlock]$GetCurrentDateTimeMessageFormat = {(Get-Date).ToString($DateTimeMessageFormat)}
              $DateFileFormat = 'yyyyMMdd'  ###20190403###
              [ScriptBlock]$GetCurrentDateFileFormat = {(Get-Date).ToString($DateFileFormat)}
              $DateTimeFileFormat = 'yyyyMMdd_HHmmss'  ###20190403_115354###
              [ScriptBlock]$GetCurrentDateTimeFileFormat = {(Get-Date).ToString($DateTimeFileFormat)}
              [System.IO.FileInfo]$ScriptPath = "$($MyInvocation.MyCommand.Definition)"
              [System.IO.DirectoryInfo]$ScriptDirectory = "$($ScriptPath.Directory.FullName)"
              [System.IO.DirectoryInfo]$FunctionsDirectory = "$($ScriptDirectory.FullName)\Functions"
              [System.IO.DirectoryInfo]$System32Directory = "$([System.Environment]::SystemDirectory)"
              [ScriptBlock]$GetRandomGUID = {[System.GUID]::NewGUID().GUID.ToString().ToUpper()}
              [String]$ParameterSetName = "$($PSCmdlet.ParameterSetName)"
              $TextInfo = (Get-Culture).TextInfo
              $Script:LASTEXITCODE = 0
              $TerminationCodes = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                $TerminationCodes.Add('Success', @(0))
                $TerminationCodes.Add('Warning', @(5000..5999))
                $TerminationCodes.Add('Error', @(6000..6999))
              $LoggingDetails = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'    
                $LoggingDetails.Add('LogMessage', $Null)
                $LoggingDetails.Add('WarningMessage', $Null)
                $LoggingDetails.Add('ErrorMessage', $Null)
              $RegexOptionList = New-Object -TypeName 'System.Collections.Generic.List[System.Text.RegularExpressions.RegexOptions]'
                $RegexOptionList.Add('IgnoreCase')
                $RegexOptionList.Add('Multiline')
              $RegularExpressionTable = New-Object -TypeName 'System.Collections.Generic.Dictionary[[String], [System.Text.RegularExpressions.Regex]]'
                $RegularExpressionTable.Base64 = New-Object -TypeName 'System.Text.RegularExpressions.Regex' -ArgumentList @('^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{4})$', $RegexOptionList.ToArray())
              $CommonParameterList = New-Object -TypeName 'System.Collections.Generic.List[String]'
                $CommonParameterList.AddRange([System.Management.Automation.PSCmdlet]::CommonParameters)
                $CommonParameterList.AddRange([System.Management.Automation.PSCmdlet]::OptionalCommonParameters)
              $TextEncoder = [System.Text.Encoding]::Default

              #Define the error handling definition
                [ScriptBlock]$ErrorHandlingDefinition = {
                                                            Param
                                                              (
                                                                  [Int16]$Severity,
                                                                  [Boolean]$ContinueOnError
                                                              )
                                                                                                                
                                                            $ExceptionPropertyDictionary = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                                                              $ExceptionPropertyDictionary.Message = $_.Exception.Message
                                                              $ExceptionPropertyDictionary.Category = $_.Exception.ErrorRecord.FullyQualifiedErrorID
                                                              $ExceptionPropertyDictionary.Script = Try {[System.IO.Path]::GetFileName($_.InvocationInfo.ScriptName)} Catch {$Null}
                                                              $ExceptionPropertyDictionary.LineNumber = $_.InvocationInfo.ScriptLineNumber
                                                              $ExceptionPropertyDictionary.LinePosition = $_.InvocationInfo.OffsetInLine
                                                              $ExceptionPropertyDictionary.Code = $_.InvocationInfo.Line.Trim()

                                                            $ExceptionMessageList = New-Object -TypeName 'System.Collections.Generic.List[String]'

                                                            ForEach ($ExceptionProperty In $ExceptionPropertyDictionary.GetEnumerator())
                                                              {
                                                                  Switch ($Null -ine $ExceptionProperty.Value)
                                                                    {
                                                                        {($_ -eq $True)}
                                                                          {
                                                                              $ExceptionMessageList.Add("[$($ExceptionProperty.Key): $($ExceptionProperty.Value)]")
                                                                          }
                                                                    }   
                                                              }

                                                            $LogMessageParameters = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                                                              $LogMessageParameters.Message = $ExceptionMessageList -Join ' '
                                                              $LogMessageParameters.Verbose = $True
                              
                                                            Switch ($Severity)
                                                              {
                                                                  {($_ -in @(1))} {Write-Verbose @LogMessageParameters}
                                                                  {($_ -in @(2))} {Write-Warning @LogMessageParameters}
                                                                  {($_ -in @(3))} {Write-Error @LogMessageParameters}
                                                              }

                                                            Switch ($ContinueOnError)
                                                              {
                                                                  {($_ -eq $False)}
                                                                    {                  
                                                                        If (($Null -ieq $Script:LASTEXITCODE) -or ($Script:LASTEXITCODE -eq 0))
                                                                          {
                                                                              [Int]$Script:LASTEXITCODE = 6000

                                                                              [System.Environment]::ExitCode = $Script:LASTEXITCODE
                                                                          }
                                                                    
                                                                        Throw
                                                                    }
                                                              }
                                                        }
	            
            #Determine default parameter value(s)                  
              Switch ($True)
                {
                    {([String]::IsNullOrEmpty($DownloadDirectory) -eq $True) -or ([String]::IsNullOrWhiteSpace($DownloadDirectory) -eq $True)}
                      {
                          [System.IO.DirectoryInfo]$DownloadDirectory = "$($Env:Public)\Documents\Get-AutomoxAPIData"
                      }
    
                    {([String]::IsNullOrEmpty($LogDirectory) -eq $True) -or ([String]::IsNullOrWhiteSpace($LogDirectory) -eq $True)}
                      {
                          [System.IO.DirectoryInfo]$LogDirectory = "$($DownloadDirectory.FullName)\Logs"
                      }       
                }

            #Start transcripting (Logging)
              [System.IO.FileInfo]$ScriptLogPath = "$($LogDirectory.FullName)\$($ScriptPath.BaseName)_$($GetCurrentDateTimeFileFormat.Invoke()).log"
              If ($ScriptLogPath.Directory.Exists -eq $False) {$Null = [System.IO.Directory]::CreateDirectory($ScriptLogPath.Directory.FullName)}
              Start-Transcript -Path "$($ScriptLogPath.FullName)" -Force -WhatIf:$False
	
            #Log any useful information                                     
              [String]$CmdletName = $MyInvocation.MyCommand.Name
                                                   
              $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Execution of script `"$($CmdletName)`" began on $($ScriptStartTime.ToString($DateTimeLogFormat))"
              Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose

              $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Script Path = $($ScriptPath.FullName)"
              Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose

              $AvailableScriptParameterList = (Get-Command -Name ($ScriptPath.FullName)).Parameters.GetEnumerator() | Where-Object {($_.Value.Name -inotin $CommonParameterList)}

              [String[]]$AvailableScriptParameters = $AvailableScriptParameterList | ForEach-Object {"-$($_.Value.Name):$($_.Value.ParameterType.Name)"}
              $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Available Script Parameter(s) = $($AvailableScriptParameters -Join ', ')"
              Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose

              [String[]]$SuppliedScriptParameters = $PSBoundParameters.GetEnumerator() | ForEach-Object {Try {"-$($_.Key):$($_.Value.GetType().Name)"} Catch {"-$($_.Key):Unknown"}}
              $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Supplied Script Parameter(s) = $($SuppliedScriptParameters -Join ', ')"
              Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose
          
              Switch ($True)
                {
                    {([String]::IsNullOrEmpty($ParameterSetName) -eq $False) -and ([String]::IsNullOrWhiteSpace($ParameterSetName) -eq $False)}
                      {
                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Parameter Set Name = $($ParameterSetName)"
                          Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose
                      }
                }
                
              $ExecutionPolicyList = Get-ExecutionPolicy -List
  
              For ($ExecutionPolicyListIndex = 0; $ExecutionPolicyListIndex -lt $ExecutionPolicyList.Count; $ExecutionPolicyListIndex++)
                {
                    $ExecutionPolicy = $ExecutionPolicyList[$ExecutionPolicyListIndex]

                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - The powershell execution policy is currently set to `"$($ExecutionPolicy.ExecutionPolicy.ToString())`" for the `"$($ExecutionPolicy.Scope.ToString())`" scope."
                    Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose
                }

            #region Ensure that the version of Powershell is adequate for proper execution
              [System.Version]$MinimumPowershellVersion = '3.0.0.0'
              [System.Version]$CurrentPowershellVersion = $PSVersionTable.PSVersion
                      
              $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Minimum Powershell Version: $($MinimumPowershellVersion)"
              Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose:$False
                    
              $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Current Powershell Version: $($CurrentPowershellVersion)"
              Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose:$False
                    
              Switch (($CurrentPowershellVersion.Major -lt $MinimumPowershellVersion.Major) -and ($CurrentPowershellVersion.Minor -lt $MinimumPowershellVersion.Minor) -and ($CurrentPowershellVersion.Build -ge $MinimumPowershellVersion.Build) -and ($CurrentPowershellVersion.Revision -ge $MinimumPowershellVersion.Revision))
                {
                    {($_ -eq $True)}
                      {
                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Minimum Powershell version has not been met. No further action will be taken."
                          Write-Warning -Message ($LoggingDetails.LogMessage) -Verbose
                          
                          $ErrorHandlingDefinition.Invoke(2, $ContinueOnError.IsPresent)
                      }
                              
                    Default
                      {
                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - The minimum Powershell version requirement has been met."
                          Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose:$False
                      }
                }
            #endregion
    
            #region Log Cleanup
              [Int]$MaximumLogHistory = 3
          
              $LogList = Get-ChildItem -Path ($LogDirectory.FullName) -Filter "$($ScriptPath.BaseName)_*" -Recurse -Force | Where-Object {($_ -is [System.IO.FileInfo])}

              $SortedLogList = $LogList | Sort-Object -Property @('LastWriteTime') -Descending | Select-Object -Skip ($MaximumLogHistory)

              Switch ($SortedLogList.Count -gt 0)
                {
                    {($_ -eq $True)}
                      {
                          $LoggingDetails.WarningMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - There are $($SortedLogList.Count) log file(s) requiring cleanup."
                          Write-Warning -Message ($LoggingDetails.WarningMessage) -Verbose
                      
                          For ($SortedLogListIndex = 0; $SortedLogListIndex -lt $SortedLogList.Count; $SortedLogListIndex++)
                            {
                                Try
                                  {
                                      $Log = $SortedLogList[$SortedLogListIndex]

                                      $LogAge = New-TimeSpan -Start ($Log.LastWriteTime) -End (Get-Date)

                                      $LoggingDetails.WarningMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Attempting to cleanup log file `"$($Log.FullName)`". Please Wait... [Last Modified: $($Log.LastWriteTime.ToString($DateTimeMessageFormat))] [Age: $($LogAge.Days.ToString()) day(s); $($LogAge.Hours.ToString()) hours(s); $($LogAge.Minutes.ToString()) minute(s); $($LogAge.Seconds.ToString()) second(s)]."
                                      Write-Warning -Message ($LoggingDetails.WarningMessage) -Verbose
                  
                                      $Null = [System.IO.File]::Delete($Log.FullName)
                                  }
                                Catch
                                  {
                  
                                  }   
                            }
                      }

                    Default
                      {
                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - There are $($SortedLogList.Count) log file(s) requiring cleanup."
                          Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose
                      }
                }
            #endregion
        
            #region Dot Source Dependency Scripts
              #Dot source any additional script(s) from the functions directory. This will provide flexibility to add additional functions without adding complexity to the main script and to maintain function consistency.
                Try
                  {
                      If ($FunctionsDirectory.Exists -eq $True)
                        {
                            $AdditionalFunctionsFilter = New-Object -TypeName 'System.Collections.Generic.List[String]'
                              $AdditionalFunctionsFilter.Add('*.ps1')
        
                            $AdditionalFunctionsToImport = Get-ChildItem -Path "$($FunctionsDirectory.FullName)" -Include ($AdditionalFunctionsFilter) -Recurse -Force | Where-Object {($_ -is [System.IO.FileInfo])}
        
                            $AdditionalFunctionsToImportCount = $AdditionalFunctionsToImport | Measure-Object | Select-Object -ExpandProperty Count
        
                            If ($AdditionalFunctionsToImportCount -gt 0)
                              {                    
                                  ForEach ($AdditionalFunctionToImport In $AdditionalFunctionsToImport)
                                    {
                                        Try
                                          {
                                              $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Attempting to dot source the functions contained within the dependency script `"$($AdditionalFunctionToImport.Name)`". Please Wait... [Script Path: `"$($AdditionalFunctionToImport.FullName)`"]"
                                              Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose
                          
                                              . "$($AdditionalFunctionToImport.FullName)"
                                          }
                                        Catch
                                          {
                                              $ErrorHandlingDefinition.Invoke(2, $ContinueOnError.IsPresent)
                                          }
                                    }
                              }
                        }
                  }
                Catch
                  {
                      $ErrorHandlingDefinition.Invoke(2, $ContinueOnError.IsPresent)
                  }
            #endregion

            #region Perform script action(s)
              Try
                {                                              
                    #region Download additional content from the specified Github repository
                      $GetGitRepositoryListingParameters = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
	                      $GetGitRepositoryListingParameters.BaseURI = 'https://api.github.com'
	                      $GetGitRepositoryListingParameters.RepositoryOwner = "automox"
	                      $GetGitRepositoryListingParameters.RepositoryName = "powershell-sdk"
	                      $GetGitRepositoryListingParameters.RepositoryPath = "Get-AutomoxAPIData"
                        $GetGitRepositoryListingParameters.RepositoryBranch = "main"
	                      $GetGitRepositoryListingParameters.DestinationDirectory = "$($DownloadDirectory.FullName)"
                        $GetGitRepositoryListingParameters.Download = $False
                        $GetGitRepositoryListingParameters.Recursive = $True
                        $GetGitRepositoryListingParameters.Flatten = $False
                        $GetGitRepositoryListingParameters.Force = $False
	                      $GetGitRepositoryListingParameters.ContinueOnError = $False
	                      $GetGitRepositoryListingParameters.Verbose = $True

                      $GetGitRepositoryListingResult = Get-GitRepositoryListing @GetGitRepositoryListingParameters

                      Switch ($Null -ine $GetGitRepositoryListingResult)
                        {
                            {($_ -eq $True)}
                              {
                                  
                                  $GetGitRepositoryListingResult.RepositoryList
                                  
                              }
                        }
                    #endregion
                                                                                   
                    $Script:LASTEXITCODE = $TerminationCodes.Success[0]
                }
              Catch
                {
                    $ErrorHandlingDefinition.Invoke(2, $ContinueOnError.IsPresent)
                }
              Finally
                {                
                    Try
                      {                       
                          #Determine the date and time the function completed execution
                            $ScriptEndTime = (Get-Date)

                            $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Script execution of `"$($CmdletName)`" ended on $($ScriptEndTime.ToString($DateTimeLogFormat))"
                            Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose

                          #Log the total script execution time  
                            $ScriptExecutionTimespan = New-TimeSpan -Start ($ScriptStartTime) -End ($ScriptEndTime)

                            $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Script execution took $($ScriptExecutionTimespan.Hours.ToString()) hour(s), $($ScriptExecutionTimespan.Minutes.ToString()) minute(s), $($ScriptExecutionTimespan.Seconds.ToString()) second(s), and $($ScriptExecutionTimespan.Milliseconds.ToString()) millisecond(s)."
                            Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose
            
                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Exiting script `"$($ScriptPath.FullName)`" with exit code $($Script:LASTEXITCODE)."
                          Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose

                          Stop-Transcript
                      }
                    Catch
                      {
            
                      }
                }
            #endregion
        }

      {($_ -eq $False)}
        {
            [System.IO.FileInfo]$ScriptPath = "$($MyInvocation.MyCommand.Path)"

            $CurrentExecutionPolicy = Get-ExecutionPolicy -Scope Process

            $ArgumentList = New-Object -TypeName 'System.Collections.Generic.List[String]'
              $ArgumentList.Add("-ExecutionPolicy $($CurrentExecutionPolicy)")
              $ArgumentList.Add('-NoProfile')
              $ArgumentList.Add('-NoExit')
              $ArgumentList.Add('-NoLogo')
              $ArgumentList.Add("-File `"$($ScriptPath.FullName)`"")

            $ScriptInterpreterList = New-Object -TypeName 'System.Collections.Generic.List[System.String]'
              $ScriptInterpreterList.Add('powershell.exe')
              #$ScriptInterpreterList.Add('pwsh.exe')
              
            :ScriptInterpreterListLoop ForEach ($ScriptInterpreter In $ScriptInterpreterList)
              {
                  $ScriptInterpreterObject = Try {Get-Command -Name ($ScriptInterpreter) -ErrorAction SilentlyContinue} Catch {$Null}
                  
                  Switch ($Null -ine $ScriptInterpreterObject)
                    {
                        {($_ -eq $True)}
                          {
                              $Null = Start-Process -FilePath ($ScriptInterpreterObject.Path) -WorkingDirectory "$($Env:Temp.TrimEnd('\'))" -ArgumentList ($ArgumentList.ToArray()) -WindowStyle Normal -Verb RunAs -PassThru

                              Break ScriptInterpreterListLoop
                          }
                    }
              }  
        }
  }