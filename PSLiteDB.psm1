#using namespace PSLiteDB
#using namespace LiteDB

$script:QueryLDB = [LiteDB.Query]

function ConvertTo-LiteDbBSON
{
    [CmdletBinding()]
    param 
    (
        # Input object can be any powershell object
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object[]]
        $InputObject,

        # Serialization Depth
        [Parameter(ValueFromPipelineByPropertyName)]
        [uint16]
        $Depth = 3,

        # Return Array or an Object
        [ValidateSet("Document", "Array")]
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $As = "Array"
    )
    
    begin
    {
        $bsonarray = New-Object System.Collections.Generic.List[LiteDB.BsonDocument]
    }
    
    process
    {
        foreach ($i in $InputObject) 
        {
            if ($As -eq 'Array')
            {
                $bsonarray.Add(  
                    (
                        [LiteDB.JsonSerializer]::Deserialize(
                            (
                                ConvertTo-Json  -InputObject $i -Depth $Depth
                            )
                        )
                    )
                ) 
            }
            else
            {
                [LiteDB.JsonSerializer]::Deserialize(
                    (
                        ConvertTo-Json  -InputObject $i -Depth $Depth
                    )
                )
            }
        }
        
    }
    
    end
    {
        if ($bsonarray.Count -gt 0)
        {
            Write-Output $bsonarray
        }
    }
}


function Update-XYRecord
{
    [CmdletBinding()]
    [Alias("uxy")]
    param 
    (
        [Parameter(ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [String]
        $Collection = "XY"
    )
    
    begin
    {
        
    }
    
    process
    {
        $tagsource = Join-Path $env:APPDATA -ChildPath XYPlorer\Tag.dat
        [PSLiteDB.FileSystem.CRUD]::Upsert(([PSLiteDB.FileSystem.CRUD]::GetXYplorerFile($tagsource)),$Collection)       
    }
    
    end
    {

    }
}

function Set-XYIndex
{
    [CmdletBinding()]
    [ALias("CreateXYIndex")]
    param 
    (
        [Parameter(ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [String]
        $Collection = "XY"
    )
    
    begin
    {
        
    }
    
    process
    {
        [PSLiteDB.FileSystem.CRUD]::CreateIndex($Collection)       
    }
    
    end
    {

    }
}

function Get-XYIndex
{
    [CmdletBinding()]
    [Alias("gixy")]
    param 
    (
        [Parameter(ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [String]
        $Collection = "XY"
    )
    
    begin
    {
        
    }
    
    process
    {
        [PSLiteDB.FileSystem.CRUD]::GetIndex($Collection)       
    }
    
    end
    {

    }
}

function Get-XYPlorerFile
{
    [CmdletBinding()]
    param 
    (
        [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [String]
        $tagsource = (Join-Path $env:APPDATA -ChildPath XYPlorer\Tag.dat)
    )
    
    begin
    {
        
    }
    
    process
    {
        #$tagsource = Join-Path $env:APPDATA -ChildPath XYPlorer\Tag.dat
        [PSLiteDB.FileSystem.CRUD]::GetXYplorerFile($tagsource)   
    }
    
    end
    {

    }
}


function Find-XYRecord
{
    [CmdletBinding()]
    [Alias("fxy")]
    param 
    (
        [Parameter(ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [String]
        $Collection = "XY",

        [Alias("Tags")]
        [Parameter(ValueFromPipelineByPropertyName,Position = 0)]
        [String[]]
        $Tag,    
        
        #[Alias("BaseName")]
        [Parameter(ValueFromPipelineByPropertyName,Position = 1)]
        [String[]]
        $BaseName ,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]
        $Limit = 50,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]
        $Skip = 0          

    )
    
    begin
    {
        
    }
    
    process
    {           
        if ($BaseName -and $Tag) 
        {

            Write-Verbose "name::$basename & Tag::$Tag"
            [PSLiteDB.FileSystem.CRUD]::FindbyTagNameList($BaseName,$Tag,$Collection)               
        }
        elseif ($BaseName -and (-not $Tag)) 
        {
            Write-Verbose "name::$basename"
            [PSLiteDB.FileSystem.CRUD]::FindbyNameList($BaseName,$Collection)
        }
        elseif ($Tag -and (-not $BaseName)) 
        {
            Write-Verbose "Tag::$Tag"
            [PSLiteDB.FileSystem.CRUD]::FindbyTagList($Tag,$Collection)
        }
        else 
        {
            [PSLiteDB.FileSystem.CRUD]::List($Limit,$Skip,$Collection)
        }
             
    }
    
    end
    {

    }
}


function Remove-XYOrphan
{
    [CmdletBinding()]
    param 
    (
        [Parameter(ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [String]
        $Collection = "XY"
    )
    
    begin
    {
        
    }
    
    process
    {
        [PSLiteDB.FileSystem.CRUD]::RemoveOrphans($Collection)       
    }
    
    end
    {

    }
}


Export-ModuleMember -Variable QueryLDB -Function * -Alias *