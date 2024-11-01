## Microsoft Function Naming Convention: http://msdn.microsoft.com/en-us/library/ms714428(v=vs.85).aspx

#region Function Get-GitRepositoryListing
Function Get-GitRepositoryListing
    {
        <#
          .SYNOPSIS
          List or download files from public and private Git repositories.
          
          .DESCRIPTION
          Leverages the Github API to list the files within public and private Git repositories along with the capability to download the files whilst maintaining the folder structure.
          
          .PARAMETER AccessToken
          Your parameter description

          .PARAMETER BaseURI
          Your parameter description

          .PARAMETER RepositoryOwner
          Your parameter description

          .PARAMETER RepositoryName
          Your parameter description

          .PARAMETER RepositoryPath
          Your parameter description

          .PARAMETER RepositoryBranch
          Your parameter description

          .PARAMETER DestinationDirectory
          Your parameter description

          .PARAMETER Download
          Your parameter description

          .PARAMETER Recursive
          Your parameter description

          .PARAMETER Flatten
          Your parameter description

          .PARAMETER Force
          Your parameter description

          .PARAMETER ContinueOnError
          Your parameter description
          
          .EXAMPLE
          Place some code here to show how to use your function

          .EXAMPLE
          Download from a public Git repository without using an access token.

          $GetGitRepositoryListingParameters = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
	          $GetGitRepositoryListingParameters.BaseURI = 'https://api.github.com'
	          $GetGitRepositoryListingParameters.RepositoryOwner = "RepositoryOwner"
	          $GetGitRepositoryListingParameters.RepositoryName = "RepositoryName"
	          $GetGitRepositoryListingParameters.RepositoryPath = "RepositoryPath"
            $GetGitRepositoryListingParameters.RepositoryBranch = "RepositoryBranch"
	          $GetGitRepositoryListingParameters.DestinationDirectory = "$($Env:Userprofile)\Downloads\Get-GitRepositoryListing"
	          $GetGitRepositoryListingParameters.Download = $False
	          $GetGitRepositoryListingParameters.Recursive = $True
            $GetGitRepositoryListingParameters.Flatten = $False
	          $GetGitRepositoryListingParameters.Force = $False
	          $GetGitRepositoryListingParameters.ContinueOnError = $False
	          $GetGitRepositoryListingParameters.Verbose = $True

          $GetGitRepositoryListingResult = Get-GitRepositoryListing @GetGitRepositoryListingParameters

          Write-Output -InputObject ($GetGitRepositoryListingResult)

          .EXAMPLE
          Download from a private Git repository by using an access token.

          $GetGitRepositoryListingParameters = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
	          $GetGitRepositoryListingParameters.AccessToken = "YourAccessToken"
	          $GetGitRepositoryListingParameters.BaseURI = 'https://api.github.com'
	          $GetGitRepositoryListingParameters.RepositoryOwner = "RepositoryOwner"
	          $GetGitRepositoryListingParameters.RepositoryName = "RepositoryName"
	          $GetGitRepositoryListingParameters.RepositoryPath = "RepositoryPath"
            $GetGitRepositoryListingParameters.RepositoryBranch = "RepositoryBranch"
	          $GetGitRepositoryListingParameters.DestinationDirectory = "$($Env:Userprofile)\Downloads\Get-GitRepositoryListing"
	          $GetGitRepositoryListingParameters.Download = $False
	          $GetGitRepositoryListingParameters.Recursive = $True
            $GetGitRepositoryListingParameters.Flatten = $False
	          $GetGitRepositoryListingParameters.Force = $False
	          $GetGitRepositoryListingParameters.ContinueOnError = $False
	          $GetGitRepositoryListingParameters.Verbose = $True

          $GetGitRepositoryListingResult = Get-GitRepositoryListing @GetGitRepositoryListingParameters

          Write-Output -InputObject ($GetGitRepositoryListingResult)
  
          .NOTES
          This function could also theoretically support Git repositories outside of Github, such as Gitea, or Gitlab.
          
          .LINK
          https://docs.github.com/v3/repos/contents/
        #>
        
        [CmdletBinding(ConfirmImpact = 'Low')]
       
        Param
          (        
		          [Parameter(Mandatory=$False)]
              [ValidateNotNullOrEmpty()]
		          [System.String]$AccessToken,

              [Parameter(Mandatory=$False)]
              [ValidateNotNullOrEmpty()]
		          [System.URI]$BaseURI,

		          [Parameter(Mandatory=$True)]
              [ValidateNotNullOrEmpty()]
		          [System.String]$RepositoryOwner,

		          [Parameter(Mandatory=$True)]
              [ValidateNotNullOrEmpty()]
		          [System.String]$RepositoryName,

		          [Parameter(Mandatory=$True)]
              [ValidateNotNullOrEmpty()]
		          [System.String]$RepositoryPath,

		          [Parameter(Mandatory=$False)]
              [ValidateNotNullOrEmpty()]
		          [System.String]$RepositoryBranch,

		          [Parameter(Mandatory=$False)]
              [ValidateNotNullOrEmpty()]
		          [System.IO.DirectoryInfo]$DestinationDirectory,
  
              [Parameter(Mandatory=$False)]
              [Switch]$Download,

              [Parameter(Mandatory=$False)]
              [Switch]$Recursive,

              [Parameter(Mandatory=$False)]
              [Switch]$Flatten,

              [Parameter(Mandatory=$False)]
              [Switch]$Force,
                                            
              [Parameter(Mandatory=$False)]
              [Switch]$ContinueOnError        
          )
                    
        Begin
          {
              Try
                {
                    $DateTimeLogFormat = 'dddd, MMMM dd, yyyy @ hh:mm:ss.FFF tt'  ###Monday, January 01, 2019 @ 10:15:34.000 AM###
                    [ScriptBlock]$GetCurrentDateTimeLogFormat = {(Get-Date).ToString($DateTimeLogFormat)}
                    $DateTimeMessageFormat = 'MM/dd/yyyy HH:mm:ss.FFF'  ###03/23/2022 11:12:48.347###
                    [ScriptBlock]$GetCurrentDateTimeMessageFormat = {(Get-Date).ToString($DateTimeMessageFormat)}
                    $DateFileFormat = 'yyyyMMdd'  ###20190403###
                    [ScriptBlock]$GetCurrentDateFileFormat = {(Get-Date).ToString($DateFileFormat)}
                    $DateTimeFileFormat = 'yyyyMMdd_HHmmss'  ###20190403_115354###
                    [ScriptBlock]$GetCurrentDateTimeFileFormat = {(Get-Date).ToString($DateTimeFileFormat)}
                    $TextInfo = (Get-Culture).TextInfo
                    $LoggingDetails = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'    
                      $LoggingDetails.LogMessage = $Null
                      $LoggingDetails.WarningMessage = $Null
                      $LoggingDetails.ErrorMessage = $Null
                    $CommonParameterList = New-Object -TypeName 'System.Collections.Generic.List[String]'
                      $CommonParameterList.AddRange([System.Management.Automation.PSCmdlet]::CommonParameters)
                      $CommonParameterList.AddRange([System.Management.Automation.PSCmdlet]::OptionalCommonParameters)

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
                                                                            Throw
                                                                        }
                                                                  }
                                                            }
                    
                    #Determine the date and time we executed the function
                      $FunctionStartTime = (Get-Date)
                    
                    [String]$FunctionName = $MyInvocation.MyCommand
                    [System.IO.FileInfo]$InvokingScriptPath = $MyInvocation.PSCommandPath
                    [System.IO.DirectoryInfo]$InvokingScriptDirectory = $InvokingScriptPath.Directory
                    [System.IO.FileInfo]$FunctionPath = "$($InvokingScriptDirectory)\Functions\$($FunctionName).ps1"
                    [System.IO.DirectoryInfo]$FunctionDirectory = "$($FunctionPath.Directory)"
                    
                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Function `'$($FunctionName)`' is beginning. Please Wait..."
                    Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose
              
                    #Define Default Action Preferences
                      $ErrorActionPreference = 'Stop'
                      
                    [String[]]$AvailableScriptParameters = (Get-Command -Name ($FunctionName)).Parameters.GetEnumerator() | Where-Object {($_.Value.Name -inotin $CommonParameterList)} | ForEach-Object {"-$($_.Value.Name):$($_.Value.ParameterType.Name)"}
                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Available Function Parameter(s) = $($AvailableScriptParameters -Join ', ')"
                    Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose

                    [String[]]$SuppliedScriptParameters = $PSBoundParameters.GetEnumerator() | ForEach-Object {Try {"-$($_.Key):$($_.Value.GetType().Name)"} Catch {"-$($_.Key):Unknown"}}
                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Supplied Function Parameter(s) = $($SuppliedScriptParameters -Join ', ')"
                    Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose

                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Execution of $($FunctionName) began on $($FunctionStartTime.ToString($DateTimeLogFormat))"
                    Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose

                    #region Adjust security protocol type(s)
                      [System.Net.SecurityProtocolType]$DesiredSecurityProtocol = [System.Net.SecurityProtocolType]::TLS12
  
                      $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Attempting to set the desired security protocol to `"$($DesiredSecurityProtocol.ToString().ToUpper())`". Please Wait..."
                      Write-Verbose -Message ($LoggingDetails.LogMessage)
          
                      $Null = [System.Net.ServicePointManager]::SecurityProtocol = ($DesiredSecurityProtocol)
                    #endregion

                    #Define default parameter values
                      Switch ($True)
                        {
                            {([String]::IsNullOrEmpty($BaseURI) -eq $True) -or ([String]::IsNullOrWhiteSpace($BaseURI) -eq $True)}
                              {
                                  [System.URI]$BaseURI = 'https://api.github.com'
                              }

                            {([String]::IsNullOrEmpty($RepositoryBranch) -eq $True) -or ([String]::IsNullOrWhiteSpace($RepositoryBranch) -eq $True)}
                              {
                                  [System.String]$RepositoryBranch = 'main'
                              }

                            {([String]::IsNullOrEmpty($DestinationDirectory) -eq $True) -or ([String]::IsNullOrWhiteSpace($DestinationDirectory) -eq $True)}
                              {
                                  [System.IO.DirectoryInfo]$DestinationDirectory = "$($Env:Windir)\Temp\Github"
                              }
                        }

                    #Define helper functions
                      #region Function Convert-FileSize
                      Function Convert-FileSize
                        {
                              <#
                                .SYSNOPSIS
                                Converts a size in bytes to its upper most value.

                                .PARAMETER Size
                                The size in bytes to convert

                                .EXAMPLE
                                $ConvertFileSizeParameters = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
	                                $ConvertFileSizeParameters.Size = 4294964
	                                $ConvertFileSizeParameters.DecimalPlaces = 2

                                $ConvertFileSizeResult = Convert-FileSize @ConvertFileSizeParameters

                                Write-Output -InputObject ($ConvertFileSizeResult)

                                .EXAMPLE
                                $ConvertFileSizeResult = Convert-FileSize -Size 4294964

                                Write-Output -InputObject ($ConvertFileSizeResult)

                                .NOTES
                                Size              : 429496456565656
                                DecimalPlaces     : 0
                                Divisor           : 1099511627776
                                SizeUnit          : TB
                                SizeUnitAlias     : Terabytes
                                CalculatedSize    : 391
                                CalculatedSizeStr : 391 TB
                              #>
      
                            [CmdletBinding()]
                              Param
                                (
                                    [Parameter(Mandatory=$True)]
                                    [ValidateNotNullOrEmpty()]
                                    [Alias("Length")]
                                    $Size,

                                    [Parameter(Mandatory=$False)]
                                    [ValidateNotNullOrEmpty()]
                                    [Alias("DP")]
                                    [Int]$DecimalPlaces
                                )

                            Try
                              {
                                  Switch ($True)
                                    {
                                        {([String]::IsNullOrEmpty($DecimalPlaces) -eq $True) -or ([String]::IsNullOrWhiteSpace($DecimalPlaces) -eq $True)}
                                          {
                                              [Int]$DecimalPlaces = 2
                                          }
                                    }
            
                                  $OutputObjectProperties = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                                    $OutputObjectProperties.Size = $Size
                                    $OutputObjectProperties.DecimalPlaces = $DecimalPlaces
            
                                  Switch ($Size)
                                    {
                                        {($_ -lt 1MB)}
                                          {  
                                              $OutputObjectProperties.Divisor = 1KB   
                                              $OutputObjectProperties.SizeUnit = 'KB'
                                              $OutputObjectProperties.SizeUnitAlias = 'Kilobytes'

                                              Break
                                          }

                                        {($_ -lt 1GB)}
                                          {
                                              $OutputObjectProperties.Divisor = 1MB  
                                              $OutputObjectProperties.SizeUnit = 'MB'
                                              $OutputObjectProperties.SizeUnitAlias = 'Megabytes'

                                              Break
                                          }

                                        {($_ -lt 1TB)}
                                          {
                                              $OutputObjectProperties.Divisor = 1GB   
                                              $OutputObjectProperties.SizeUnit = 'GB'
                                              $OutputObjectProperties.SizeUnitAlias = 'Gigabytes'

                                              Break
                                          }

                                        {($_ -ge 1TB)}
                                          {
                                              $OutputObjectProperties.Divisor = 1TB
                                              $OutputObjectProperties.SizeUnit = 'TB'
                                              $OutputObjectProperties.SizeUnitAlias = 'Terabytes'

                                              Break
                                          }
                                    }

                                  $OutputObjectProperties.CalculatedSize = [System.Math]::Round(($Size / $OutputObjectProperties.Divisor), $OutputObjectProperties.DecimalPlaces)
                                  $OutputObjectProperties.CalculatedSizeStr = "$($OutputObjectProperties.CalculatedSize) $($OutputObjectProperties.SizeUnit)"
                              }
                            Catch
                              {
                                  Write-Error -Exception $_
                              }
                            Finally
                              {
                                  $OutputObject = New-Object -TypeName 'PSObject' -Property ($OutputObjectProperties)

                                  Write-Output -InputObject ($OutputObject)
                              }
                        }
                      #endregion
                    
                    #Define additional ScriptBlocks
                      [ScriptBlock]$GetTimeSpanMessage = {
                                                              Param
                                                                (
                                                                    [System.TimeSpan]$InputObject
                                                                )

                                                              $InputObjectMessageBuilder = New-Object -TypeName 'System.Text.StringBuilder'

                                                              $InputObjectProperties = $InputObject | Select-Object -Property @('Days', 'Hours', 'Minutes', 'Seconds', 'Milliseconds')
                                        
                                                              $InputObjectPropertyNameList = New-Object -TypeName 'System.Collections.Generic.List[System.String]'

                                                              ($InputObjectProperties.PSObject.Properties | Where-Object {($_.Value -gt 0)}).Name | ForEach-Object {($InputObjectPropertyNameList.Add($_))}

                                                              $InputObjectPropertyNameListUpperBound = $InputObjectPropertyNameList.ToArray().GetUpperBound(0)
                                        
                                                              For ($InputObjectPropertyNameListIndex = 0; $InputObjectPropertyNameListIndex -lt $InputObjectPropertyNameList.Count; $InputObjectPropertyNameListIndex++)
                                                                {
                                                                    $InputObjectPropertyName = $InputObjectPropertyNameList[$InputObjectPropertyNameListIndex]
                                              
                                                                    $InputObjectPropertyValue = $InputObject.$($InputObjectPropertyName)

                                                                    Switch ($True)
                                                                      {
                                                                          {($InputObjectPropertyNameList.Count -gt 1) -and ($InputObjectPropertyNameListIndex -eq $InputObjectPropertyNameListUpperBound)}
                                                                            {
                                                                                $Null = $InputObjectMessageBuilder.Append('and ')
                                                                            }
                                                    
                                                                          {($InputObjectPropertyValue -eq 1)}
                                                                            {                                                          
                                                                                $Null = $InputObjectMessageBuilder.Append("$($InputObjectPropertyValue) $($InputObjectPropertyName.TrimEnd('s').ToLower())")
                                                                            }

                                                                          {($InputObjectPropertyValue -gt 1)}
                                                                            {
                                                                                $Null = $InputObjectMessageBuilder.Append("$($InputObjectPropertyValue) $($InputObjectPropertyName.ToLower())")
                                                                            }

                                                                          {($InputObjectPropertyNameList.Count -gt 1) -and ($InputObjectPropertyNameListIndex -ne $InputObjectPropertyNameListUpperBound)}
                                                                            {
                                                                                $Null = $InputObjectMessageBuilder.Append(', ')
                                                                            }
                                                                      }
                                                                }

                                                              $OutputObject = $InputObjectMessageBuilder.ToString()
                                        
                                                              Switch ($InputObjectMessageBuilder.Length -gt 0)
                                                                {
                                                                    {($_ -eq $True)}
                                                                      { 
                                                                          $OutputObject = $InputObjectMessageBuilder.ToString()
                                                                      }

                                                                    Default
                                                                      {
                                                                          $OutputObject = 'N/A'
                                                                      }
                                                                }
                                        
                                                              Write-Output -InputObject ($OutputObject)
                                                          }
                                        
                    #Create an object that will contain the functions output.
                      $OutputObjectProperties = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                        $OutputObjectProperties.InitialRequestURI = $Null
                        $OutputObjectProperties.RepositoryList = New-Object -TypeName 'System.Collections.Generic.List[System.Management.Automation.PSObject]'
                        $OutputObjectProperties.WebRequestResponseList = New-Object -TypeName 'System.Collections.Generic.List[System.Object]'
                }
              Catch
                {
                    $ErrorHandlingDefinition.Invoke(2, $ContinueOnError.IsPresent)
                }
              Finally
                {
                    
                }
          }

        Process
          {           
              Try
                {  
                    $RepositoryPath = $RepositoryPath -ireplace '(\/{1,})|(\\{1,})', '/'
                    
                    [System.URI]$InitialRequestURI = "$($BaseURI.OriginalString)/repos/$($RepositoryOwner)/$($RepositoryName)/contents/$($RepositoryPath.TrimStart('/').TrimEnd('/'))?ref=$($RepositoryBranch)"

                    $OutputObjectProperties.InitialRequestURI = $InitialRequestURI

                    $RepositoryDirectoryBuilder = New-Object -TypeName 'System.Text.StringBuilder'
                                    
                    $GetRepositoryListing = {
                                                Param
                                                  (
                                                      [System.URI]$RequestURI,
                                                      [System.String]$AccessToken,
                                                      [Switch]$Recursive
                                                  )

                                                $InvokeWebRequestHeaders = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                                                  $InvokeWebRequestHeaders.'Accept' = 'application/vnd.github+json'
                                                  #$InvokeWebRequestHeaders.'X-GitHub-Api-Version' = '2022-11-28'
                                                
                                                Switch ($True)
                                                  {
                                                      {([String]::IsNullOrEmpty($AccessToken) -eq $False) -and ([String]::IsNullOrWhiteSpace($AccessToken) -eq $False)}
                                                        {
                                                            $InvokeWebRequestHeaders.Authorization = "Bearer $($AccessToken)"
                                                        }
                                                  }
                    
                                                $InvokeWebRequestParameters = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
	                                                $InvokeWebRequestParameters.UseBasicParsing = $True
	                                                $InvokeWebRequestParameters.Uri = $RequestURI
	                                                $InvokeWebRequestParameters.UseDefaultCredentials = $True
	                                                $InvokeWebRequestParameters.DisableKeepAlive = $False
	                                                $InvokeWebRequestParameters.TimeoutSec = 30
	                                                $InvokeWebRequestParameters.Method = 'Get'
                                                  $InvokeWebRequestParameters.ContentType = 'application/vnd.github+json'
                                                  $InvokeWebRequestParameters.UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
	                                                $InvokeWebRequestParameters.Verbose = $False

                                                Switch ($InvokeWebRequestHeaders.Keys.Count -gt 0)
                                                  {
                                                      {($_ -eq $True)}
                                                        {
                                                            $InvokeWebRequestParameters.Headers = $InvokeWebRequestHeaders
                                                        }
                                                  }

                                                $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Attempting to initiate a web request. Please Wait..." 
                                                Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Request URI: $($RequestURI)" 
                                                Write-Verbose -Message ($LoggingDetails.LogMessage)
                                                
                                                $InvokeWebRequestResult = Invoke-WebRequest @InvokeWebRequestParameters

                                                $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Status Code: $($InvokeWebRequestResult.StatusCode)" 
                                                Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                $OutputObjectProperties.WebRequestResponseList.Add($InvokeWebRequestResult)
                                                
                                                Switch ($InvokeWebRequestResult.StatusCode -in @(200))
                                                  {
                                                      {($_ -eq $True)}
                                                        {  
                                                            $WebRequestResponseContent = $InvokeWebRequestResult.Content

                                                            $RepositoryObjectList = ConvertFrom-JSON -InputObject ($WebRequestResponseContent)

                                                            $RepositoryObjectListCount = ($RepositoryObjectList | Measure-Object).Count

                                                            $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Located $($RepositoryObjectListCount) object(s) within the specified repository directory." 
                                                            Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                            $Null = $RepositoryDirectoryBuilder.Append('/').Append("$((Split-Path -Path $RequestURI -Leaf) -ireplace '(\?.*)', '')")
                                                            
                                                            $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Repository Directory: $($RepositoryDirectoryBuilder.ToString())" 
                                                            Write-Verbose -Message ($LoggingDetails.LogMessage)
                                                            
                                                            Switch ($RepositoryObjectListCount -gt 0)
                                                              {
                                                                  {($_ -eq $True)}
                                                                    {
                                                                        $RepositoryObjectListCounter = 1
                                                                        
                                                                        For ($RepositoryObjectListIndex = 0; $RepositoryObjectListIndex -lt $RepositoryObjectListCount; $RepositoryObjectListIndex++)
                                                                          {
                                                                              Try
                                                                                {
                                                                                    $RepositoryObject = $RepositoryObjectList[$RepositoryObjectListIndex]
                                                                                                                                    
                                                                                    Switch ($RepositoryObject.Type)
                                                                                      {
                                                                                          {($_ -iin @('dir'))}
                                                                                            {                                                                                                                                                                                                                                          
                                                                                                Switch ($Recursive.IsPresent)
                                                                                                  {
                                                                                                      {($_ -eq $True)}
                                                                                                        {
                                                                                                            $GetRepositoryListing.InvokeReturnAsIs($RepositoryObject.URL, $AccessToken, $Recursive.IsPresent)
                                                                                                        }
                                                                                                  }
                                                                                            }

                                                                                          {($_ -iin @('file'))}
                                                                                            {                                                                                  
                                                                                                $RepositoryObjectDirectorySegments = $RepositoryObject.Path.Split('/', [System.StringSplitOptions]::RemoveEmptyEntries) -As [System.Collections.Generic.List[System.String]]

                                                                                                $Null = $RepositoryObjectDirectorySegments.RemoveAt(0)

                                                                                                #Consider developing a way to remove additional directory segments based on the specified repository path depth. This will allow for downloading files at a directory and below to the filesystem whilst mirroring the directory structure from that level and below.
                                                                                                
                                                                                                $RepositoryObjectDirectory = ($RepositoryObjectDirectorySegments -Join '/') -ireplace '\/{1,}', '\'
                                                                                                $RepositoryObjectDirectory = $RepositoryObjectDirectory -ireplace [Regex]::Escape($RepositoryObject.Name), ''
                                                                                                $RepositoryObjectDirectory = $RepositoryObjectDirectory.TrimStart('\').TrimEnd('\')
                                                          
                                                                                                $RepositoryListingObjectProperties = New-Object -TypeName 'System.Collections.Specialized.OrderedDictionary'
                                                                                                  $RepositoryListingObjectProperties.URL = $RepositoryObject.'download_url' -As [System.URI]
                                                                                                  $RepositoryListingObjectProperties.URLEscaped = [System.URI]::EscapeURIString($RepositoryListingObjectProperties.URL)
                                                                                                  $RepositoryListingObjectProperties.RepositoryPath = $RepositoryObject.'path'
                                                                                                  $RepositoryListingObjectProperties.DestinationPath = $Null
                                                                                                  $RepositoryListingObjectProperties.ExpectedDownloadSize = $RepositoryObject.Size -As [System.UInt64]
                                                                                                  $RepositoryListingObjectProperties.ExpectedFileHash = $RepositoryObject.sha
                                                                                                  $RepositoryListingObjectProperties.DownloadStatus = 'NotAttempted'
                                                                                                  $RepositoryListingObjectProperties.DownloadStartTime = $Null
                                                                                                  $RepositoryListingObjectProperties.DownloadCompletionTime = $Null
                                                                                                  $RepositoryListingObjectProperties.DownloadDuration = $Null

                                                                                                Switch ($Flatten.IsPresent)
                                                                                                  {
                                                                                                      {($_ -eq $True)}
                                                                                                        {
                                                                                                            $RepositoryListingObjectProperties.DestinationPath = "$($DestinationDirectory)\$($RepositoryObject.Name)" -As [System.IO.FileInfo]
                                                                                                        }

                                                                                                      Default
                                                                                                        {
                                                                                                            $RepositoryListingObjectProperties.DestinationPath = "$($DestinationDirectory)\$($RepositoryObjectDirectory)\$($RepositoryObject.Name)" -As [System.IO.FileInfo]
                                                                                                        }
                                                                                                  }

                                                                                                $RepositoryListingObject = New-Object -TypeName 'System.Management.Automation.PSObject' -Property ($RepositoryListingObjectProperties)
                                                                              
                                                                                                $OutputObjectProperties.RepositoryList.Add($RepositoryListingObject)
                                                                                            }
                                                                                      }
                                                                                }
                                                                              Catch
                                                                                {
                                                                                    $ErrorHandlingDefinition.Invoke(2, $ContinueOnError.IsPresent)
                                                                                }
                                                                              Finally
                                                                                {                                                                                                                                                                        
                                                                                    $RepositoryObjectListCounter++
                                                                                }
                                                                          }
                                                                    }
                                                              }
                                                        }
                                                  }
                                            }

                    $Null = $GetRepositoryListing.InvokeReturnAsIs($InitialRequestURI.OriginalString, $AccessToken, $Recursive.IsPresent)

                    $OutputObject = New-Object -TypeName 'System.Management.Automation.PSObject' -Property ($OutputObjectProperties)

                    Try {$OutputObject.RepositoryList = $OutputObject.RepositoryList.ToArray()} Catch {}

                    Switch ($Download.IsPresent)
                      {
                          {($_ -eq $True)}
                            {
                                $RepositoryList = $OutputObject.RepositoryList
                                
                                $RepositoryListCount = ($RepositoryList | Measure-Object).Count

                                Switch ($RepositoryListCount -gt 0)
                                  {
                                      {($_ -eq $True)}
                                        {
                                            $RepositoryListCounter = 1
                                            
                                            For ($RepositoryListIndex = 0; $RepositoryListIndex -lt $RepositoryListCount; $RepositoryListIndex++)
                                              {
                                                  Try
                                                    {
                                                        $RepositoryListItem = $RepositoryList[$RepositoryListIndex]

                                                        $DownloadRepositoryListItem = {
                                                                                          Param
                                                                                            (
                                                                                                [System.Management.Automation.PSObject]$RepositoryListItem
                                                                                            )
                                                                                          
                                                                                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Attempting to download repository list item $($RepositoryListCounter) of $($RepositoryListCount). Please Wait..."
                                                                                          Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                                                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Download URL: $($RepositoryListItem.URL)"
                                                                                          Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                                                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Escaped Download URL: $($RepositoryListItem.URLEscaped)"
                                                                                          Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                                                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Destination: $($RepositoryListItem.DestinationPath)"
                                                                                          Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                                                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Size: $((Convert-FileSize -Size $RepositoryListItem.ExpectedDownloadSize).CalculatedSizeStr)"
                                                                                          Write-Verbose -Message ($LoggingDetails.LogMessage)
                                                                                          
                                                                                          $WebClient = New-Object -TypeName 'System.Net.WebClient'
                                                        
                                                                                          Switch ([System.IO.Directory]::Exists($RepositoryListItem.DestinationPath.Directory))
                                                                                            {
                                                                                                {($_ -eq $False)}
                                                                                                  {
                                                                                                      $Null = [System.IO.Directory]::CreateDirectory($RepositoryListItem.DestinationPath.Directory)
                                                                                                  }
                                                                                            }
                                                        
                                                                                          $RepositoryListItem.DownloadStatus = 'Attempted'

                                                                                          $RepositoryListItem.DownloadStartTime = Get-Date
                                                        
                                                                                          $Null = $WebClient.DownloadFile($RepositoryListItem.URLEscaped, $RepositoryListItem.DestinationPath)
                                                       
                                                                                          $RepositoryListItem.DownloadCompletionTime = Get-Date
                                                        
                                                                                          $RepositoryListItem.DownloadDuration = New-TimeSpan -Start ($RepositoryListItem.DownloadStartTime) -End ($RepositoryListItem.DownloadCompletionTime)
                                                        
                                                                                          $RepositoryListItem.DestinationPath = New-Object -TypeName 'System.IO.FileInfo' -ArgumentList @($RepositoryListItem.DestinationPath.FullName)
                                                                                          
                                                                                          $RepositoryListItem.DownloadStatus = 'Success'

                                                                                          $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Download completed in $($GetTimeSpanMessage.InvokeReturnAsIs($RepositoryListItem.DownloadDuration))"
                                                                                          Write-Verbose -Message ($LoggingDetails.LogMessage)
                                                                                      }
                                                        
                                                        Switch ([System.IO.File]::Exists($RepositoryListItem.DestinationPath))
                                                          {
                                                              {($_ -eq $True)}
                                                                {
                                                                    Switch ($Force.IsPresent)
                                                                      {
                                                                          {($_ -eq $True)}
                                                                            {
                                                                                $Null = $DownloadRepositoryListItem.InvokeReturnAsIs($RepositoryListItem)
                                                                            }

                                                                          Default
                                                                            {
                                                                                $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Skipping the download of repository list item $($RepositoryListCounter) of $($RepositoryListCount). Please Wait..."
                                                                                Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                                                $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Download URL: $($RepositoryListItem.URL)"
                                                                                Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                                                $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Escaped Download URL: $($RepositoryListItem.URLEscaped)"
                                                                                Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                                                $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Destination: $($RepositoryListItem.DestinationPath)"
                                                                                Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                                                $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Size: $((Convert-FileSize -Size $RepositoryListItem.ExpectedDownloadSize).CalculatedSizeStr)"
                                                                                Write-Verbose -Message ($LoggingDetails.LogMessage)

                                                                                $RepositoryListItem.DownloadStatus = 'Skipped'
                                                                            }
                                                                      }
                                                                }

                                                              Default
                                                                {
                                                                    $Null = $DownloadRepositoryListItem.InvokeReturnAsIs($RepositoryListItem)
                                                                }
                                                          }    
                                                    }
                                                  Catch
                                                    {
                                                        $RepositoryListItem.DownloadStatus = 'Failed'
                                                        
                                                        $ErrorHandlingDefinition.Invoke(2, $ContinueOnError.IsPresent)
                                                    }
                                                  Finally
                                                    {
                                                        $RepositoryListCounter++
                                                    }
                                              }
                                        }
                                  }
                            }
                      }
                }
              Catch
                {
                    $ErrorHandlingDefinition.Invoke(2, $ContinueOnError.IsPresent)
                }
              Finally
                {
                    
                }
          }
        
        End
          {                                        
              Try
                {
                    #Determine the date and time the function completed execution
                      $FunctionEndTime = (Get-Date)

                      $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Execution of $($FunctionName) ended on $($FunctionEndTime.ToString($DateTimeLogFormat))"
                      Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose

                    #Log the total script execution time  
                      $FunctionExecutionTimespan = New-TimeSpan -Start ($FunctionStartTime) -End ($FunctionEndTime)

                      $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Function execution took $($FunctionExecutionTimespan.Hours.ToString()) hour(s), $($FunctionExecutionTimespan.Minutes.ToString()) minute(s), $($FunctionExecutionTimespan.Seconds.ToString()) second(s), and $($FunctionExecutionTimespan.Milliseconds.ToString()) millisecond(s)"
                      Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose
                    
                    $LoggingDetails.LogMessage = "$($GetCurrentDateTimeMessageFormat.Invoke()) - Function `'$($FunctionName)`' is completed."
                    Write-Verbose -Message ($LoggingDetails.LogMessage) -Verbose
                }
              Catch
                {
                    $ErrorHandlingDefinition.Invoke(2, $ContinueOnError.IsPresent)
                }
              Finally
                {
                    Write-Output -InputObject ($OutputObject)
                }
          }
    }
#endregion