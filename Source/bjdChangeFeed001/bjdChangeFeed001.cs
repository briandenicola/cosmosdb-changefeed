using System;
using System.Collections.Generic;
using Microsoft.Azure.Documents;
using Microsoft.Azure.DocumentDB.Core;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace ChangeFeedDemo
{
    public static class bjdChangeFeed001
    {
        [FunctionName("bjdChangeFeed001")]
        public static void Run(ReadOnlyList<Document> input, Stream output, ILogger log)
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