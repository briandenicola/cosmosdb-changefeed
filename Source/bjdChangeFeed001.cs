using System;
using System.IO;
using Newtonsoft.Json;
using System.Collections;
using System.Collections.Generic;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace ChangeFeedDemo
{
    public static class bjdChangeFeed001
    {
        [FunctionName("bjdChangeFeed001")]
        public static void Run(
            [CosmosDBTrigger(
                "ToDoList", "Items",
                ConnectionStringSetting="bjdcosmos001_DOCUMENTDB",
                LeaseCollectionName="leases",
                LeaseCollectionPrefix="blob",
                CreateLeaseCollectionIfNotExists=true
            )]IReadOnlyList<Document> input, 
            Stream output, ILogger log)
        {
            if (input != null && input.Count > 0)
            {
                log.LogInformation($"Documents modified {input.Count}");
                foreach( var doc in input ) {
                    doc.SaveTo(output);
                }
            }
        }
    }
}