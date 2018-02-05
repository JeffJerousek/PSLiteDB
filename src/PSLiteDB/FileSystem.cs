using System;
using LiteDB;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace PSLiteDB
{
    public class FileEntry
    {
        public string FullName { get; set; }
        public string Name { get; set; }

        public string BaseName { get; set; }
        public string Extension { get; set; }
        public List<string> Tags { get; set; }

        public string Title { get; set; }
        public string Comment { get; set; }

        public bool Active { get; set; } = true;


    }

    public class LiteDBProvider
    {
        private static string dbpath = Path.Combine(
            Environment.GetFolderPath(
                Environment.SpecialFolder.ApplicationData
            ),
            "LiteDB", 
            "FileSystem.db"
            );

        public static LiteDatabase GetLiteDatabase()
        {
            if (!Directory.Exists(dbpath))
            {
                Directory.CreateDirectory(dbpath);
            }

            ConnectionString conn = new ConnectionString
            {
                Filename = dbpath,
                CacheSize = 5000,
                LimitSize = 5368709120,
                InitialSize = 8192,
                Mode = LiteDB.FileMode.Shared
            };

            var db = new LiteDatabase(conn);
            BsonMapper.Global.Entity<FileEntry>()
            .Id(x => x.FullName);
            BsonMapper.Global.SerializeNullValues = true;

            return db;

        }
    }

    public class CRUD
    {
        public static void Insert(FileInfo file, string Collection = "XY")
        {
            FileEntry newFile = new FileEntry
            {
                FullName = file.FullName,
                Name = file.Name,
                BaseName = Path.GetFileNameWithoutExtension(file.Name),
                Extension = file.Extension
            };

            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                if (XYCollection.FindById(newFile.FullName) == null)
                {
                    Console.WriteLine($"Adding File:\t['{newFile.FullName}']  into litedb ");
                    XYCollection.Insert(newFile);
                }
                else
                {
                    Console.WriteLine($"The file:\t['{newFile.FullName}']  already exists in litedb");
                }

            }
        }
        //INSERT

        public static void Insert(FileEntry file, string Collection = "XY")
        {

            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                if (XYCollection.FindById(file.FullName) == null)
                {
                    Console.WriteLine($"Adding File:\t['{file.FullName}']  into litedb");
                    XYCollection.Insert(file);
                }
                else
                {
                    Console.WriteLine($"The file:\t['{file.FullName}']  already exists in litedb");
                }

            }
        }
        //INSERT

        public static void Update(FileEntry file, string Collection = "XY")
        {
            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                XYCollection.Update(file);
            }
        }
        //UPDATE-1


        public static void Upsert(FileEntry file, string Collection = "XY")
        {
            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                XYCollection.Upsert(file);
            }
        }
        //UPSERT-1

        public static void Upsert(IEnumerable<FileEntry> filelist, string Collection = "XY")
        {
            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                XYCollection.Upsert(filelist);
            }
        }
        //UPSERT-2

        public static List<FileEntry> List(int Limit = 5000, int Skip = 0, string Collection = "XY")
        {
            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                //var flist = new List<FileEntry>();
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                return XYCollection.Find(Query.All(Query.Descending), Skip, Limit).ToList<FileEntry>();
            }
        }
        //LIST

        public static FileEntry FindbyID(BsonValue ID, string Collection = "XY")
        {
            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var flist = new List<FileEntry>();
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                return XYCollection.FindById(ID);
            }
        }
        //FindbyID

        public static List<FileEntry> GetXYplorerFile(string TagSource)
        {
            var flist = new List<FileEntry>();
            using (var reader = new StreamReader(TagSource))
            {
                var content = reader.ReadToEnd().Split(new string[] { Environment.NewLine }, StringSplitOptions.None);

                foreach (var l in content)
                {
                    if (l.StartsWith("C:\\", StringComparison.OrdinalIgnoreCase) || l.StartsWith("D:\\", StringComparison.OrdinalIgnoreCase) || 
                        l.StartsWith("E:\\", StringComparison.OrdinalIgnoreCase) || l.StartsWith("F:\\", StringComparison.OrdinalIgnoreCase) ||
                        l.StartsWith("G:\\", StringComparison.OrdinalIgnoreCase) || l.StartsWith("H:\\", StringComparison.OrdinalIgnoreCase)

                        )
                    {
                        var s = l.Split(new[] { "|" }, StringSplitOptions.None);

                        var fileentry = new FileEntry
                        {
                            FullName = s[0],
                            Name = Path.GetFileName(s[0]),
                            BaseName = Path.GetFileNameWithoutExtension(s[0]),
                            Extension = Path.GetExtension(s[0])
                        };

                        if (!string.IsNullOrEmpty(s[2]))
                        {
                            fileentry.Tags = s[2].Split(',').ToList();

                        }
                        if (!string.IsNullOrEmpty(s[8]))
                        {
                            fileentry.Comment = s[8];

                        }
                        flist.Add(fileentry);
                    }
                }
            }

            return flist;

        }
        //GetXYplorerFIle

        public static void CreateIndex(string Collection = "XY")
        {
            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                XYCollection.EnsureIndex(x => x.FullName, true);
                XYCollection.EnsureIndex(x => x.BaseName, "LOWER($.BaseName)", false);
                XYCollection.EnsureIndex(x => x.Name, "LOWER($.Name)", false);
                XYCollection.EnsureIndex(x => x.BaseName, false);
                XYCollection.EnsureIndex(x => x.Name, false);
                XYCollection.EnsureIndex(x => x.Tags, "LOWER($.Tags[*])", false);
            }
        }

        public static List<IndexInfo> GetIndex(string Collection = "XY")
        {
            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                return XYCollection.GetIndexes().ToList<IndexInfo>();
            }
        }

        //Find-3

        public static List<FileEntry> FindbyNameList(string[] Name, string Collection = "XY")
        {

            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);

                if (Name.Count() > 1)
                {
                    // create a new list
                    var list = new List<Query>();

                    foreach (var t in Name)
                    {
                        list.Add(Query.StartsWith("Name", t));
                    }

                    var query = Query.Or(list.ToArray());
                    return XYCollection.Find(query).ToList<FileEntry>();
                }
                else
                {
                    return XYCollection.Find(Query.StartsWith("Name", Name[0])).ToList<FileEntry>();
                }


            }
        }

        public static List<FileEntry> FindbyTagList(string[] Tag, string Collection = "XY")
        {

            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);

                if (Tag.Count() > 1)
                {
                    // create a new list
                    var list = new List<Query>();

                    foreach (var t in Tag)
                    {
                        list.Add(Query.Contains("Tags", t));
                    }

                    var query = Query.And(list.ToArray());
                    return XYCollection.Find(query).ToList<FileEntry>();
                }
                else
                {
                    return XYCollection.Find(Query.Contains("Tags", Tag[0])).ToList<FileEntry>();
                }


            }
        }
        //FIND-4

        public static List<FileEntry> FindbyTagNameList(string[] Name, string[] Tag, string Collection = "XY")
        {
            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                var namelist = new List<Query>();
                var list = new List<Query>();

                if (Name.Count() > 1)
                {
                    foreach (var n in Name)
                    {
                        namelist.Add(Query.StartsWith("Name", n));
                    }
                    list.Add(Query.Or(namelist.ToArray()));
                }
                else
                {
                    list.Add(Query.StartsWith("Name", Name[0]));
                }

                foreach (var t in Tag)
                {
                    list.Add(Query.Contains("Tags", t));
                }

                var query = Query.And(list.ToArray());
                return XYCollection.Find(query).ToList<FileEntry>();
            }
        }
        //FIND-4

        public static void RemoveOrphans(string Collection = "XY")
        {
            using (var liteDatabase = LiteDBProvider.GetLiteDatabase())
            {
                var XYCollection = liteDatabase.GetCollection<FileEntry>(Collection);
                var XYCollectionOrphan = liteDatabase.GetCollection<FileEntry>("XYOrphans");

                foreach (var f in XYCollection.FindAll())
                {
                    if (!File.Exists(f.FullName))
                    {
                        //copy file to orphan collection
                        XYCollectionOrphan.Insert(f);

                        //delete from original collection
                        XYCollection.Delete(f.FullName);
                    }
                }

            }
        }
    }
    //CRUD
}
