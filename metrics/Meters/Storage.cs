﻿using Azure.Core;
using Azure.ResourceManager.Storage;
using Azure.ResourceManager.Storage.Models;
using Azure.ResourceManager.Resources;
using Microsoft.Extensions.Logging;
using System.Diagnostics.Metrics;
using metrics;

namespace metrics.Meters
{
    // collects metrics that show on the page of quotas for Compute
    public class StorageMeter : Helper<int>
    {
        static public string MeterName = Constants.MeterBaseName + "StoragePageMeter";
        public StorageMeter(ILogger logger, AzureContext context) :
             base(
             logger,
             MeterName,
             "storage-page",
             "The usage of accounts",
             "The limit of accounts",
             (subscription, location) => new metrics.Quotas.Storage(subscription, location),
             context)
        {
        }
    }
}
