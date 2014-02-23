using System;
using System.Collections.Generic;
using System.Linq;
using MongoDB.Bson;
using MongoDB.Driver;
using MongoDB.Driver.Builders;
using MongoDB.Driver.Linq;


namespace data_generator
{
    public class FlagLetter
    {
        public ObjectId Id { get; set; }
        public int Position { get; set; }
        public char Letter { get; set; }
    }

    public class Task
    {
        public FlagLetter Letter { get; set; }
        public bool Remove { get; set; }
    }

    class Program
    {
        private const string Flag = "RUCTF_CFDE28B7B90447B582F82B7B9056B7F1";

        private const string Charset = "1234567890_QWERTYUIOPASDFGHJKLZXCVBNM";

        private const string ConnectionString = "mongodb://localhost";
        private const string DatabaseName = "ructf";
        private const string CollectionName = "letters";
        private const int DeletedItems = 31337;

        private static readonly Random random = new Random();

        private static MongoCollection<FlagLetter> GetCollection()
        {
            var client = new MongoClient(ConnectionString);
            var server = client.GetServer();
            var database = server.GetDatabase(DatabaseName);
            return database.GetCollection<FlagLetter>(CollectionName);
        }

        private static IEnumerable<Task> CreateFlagTasks(string flag)
        {
            int pos = 0;
            return flag.Select(c => new Task
            {
                Letter = new FlagLetter
                {
                    Letter = c, 
                    Position = pos++
                },
                Remove = false
            });
        }

        private static IEnumerable<Task> CreateRandomTasks(int count, int flagLength)
        {
            return Enumerable.Range(0, count).Select(x => new Task
            {
                Letter = new FlagLetter
                {
                    Letter = Charset[random.Next(Charset.Length)],
                    Position = random.Next(flagLength)
                },
                Remove = true
            });
        }

        private static void ProcessTasks(MongoCollection<FlagLetter> collection, List<Task> tasks)
        {
            tasks.Shuffle();
            foreach (var task in tasks)
                collection.Insert(task.Letter);
            tasks.Shuffle();
            foreach (var task in tasks.Where(task => task.Remove))
                collection.Remove(Query<FlagLetter>.EQ(x => x.Id, task.Letter.Id));
        }

        private static string GetFlag(MongoCollection<FlagLetter> collection)
        {
            var letters = collection.AsQueryable().OrderBy(x => x.Position).Select(x => x.Letter);
            return string.Join("", letters);
        }

        static void Main(string[] args)
        {
            var collection = GetCollection();
            var tasks = new List<Task>();
            tasks.AddRange(CreateFlagTasks(Flag));
            tasks.AddRange(CreateRandomTasks(DeletedItems, Flag.Length));
            ProcessTasks(collection, tasks);
            Console.WriteLine("Flag: {0}", GetFlag(collection));
        }
    }
}
