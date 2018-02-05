using namespace PSLiteDB
using namespace LiteDB

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
    [ALias("Uxy")]
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
        [CRUD]::Upsert([CRUD]::GetXYplorerFile($tagsource),$Collection)       
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
        [CRUD]::CreateIndex($Collection)       
    }
    
    end
    {

    }
}

function Get-XYIndex
{
    [CmdletBinding()]
    [ALias("gixy")]
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
        [CRUD]::GetIndex($Collection)       
    }
    
    end
    {

    }
}


function Find-XYRecord
{
    [CmdletBinding()]
    [ALias("FXY")]
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
            [CRUD]::FindbyTagNameList($BaseName,$Tag,$Collection)               
        }
        elseif ($BaseName -and (-not $Tag)) 
        {
            Write-Verbose "name::$basename"
            [CRUD]::FindbyNameList($BaseName,$Collection)
        }
        elseif ($Tag -and (-not $BaseName)) 
        {
            Write-Verbose "Tag::$Tag"
            [CRUD]::FindbyTagList($Tag,$Collection)
        }
        else 
        {
            [CRUD]::List($Limit,$Skip,$Collection)
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
        [CRUD]::RemoveOrphans($Collection)       
    }
    
    end
    {

    }
}


Export-ModuleMember -Variable QueryLDB -Function ConvertTo-LiteDBBSON