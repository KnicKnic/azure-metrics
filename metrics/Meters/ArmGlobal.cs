﻿using Azure.Core;
using Azure.ResourceManager.Compute;
using Azure.ResourceManager.Compute.Models;
using Azure.ResourceManager.Resources;
using Microsoft.Extensions.Logging;
using System.Diagnostics.Metrics;


namespace metrics.Meters
{
    public class ArmGlobal : Helper<long>
    {
        static public string MeterName = Constants.MeterBaseName + "ArmMeter";
        public ArmGlobal(ILogger logger, AzureContext globalContext, Tuple<string, int>[] armLimits) :
             base(
             logger,
             MeterName,
             "arm-page",
             "The usage of arm objects",
             "The limit of arm objects",
             (subscription, location) => new metrics.Quotas.ArmGlobal(subscription, location, armLimits),
             globalContext,
             true)
        {
        }
    }
}

