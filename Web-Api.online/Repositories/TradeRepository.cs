﻿using Dapper;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using Web_Api.online.Models.StoredProcedures;
using Web_Api.online.Models;
using System;

namespace Web_Api.online.Repositories
{
    public class TradeRepository
    {
        private readonly IConfiguration _configuration;

        public TradeRepository(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task<List<spGet_BTC_USDT_OpenOrdersResult>> Get_BTC_USDT_OpenOrdersAsync()
        {
            using (IDbConnection db = new SqlConnection(_configuration.GetConnectionString("ExchangeConnection")))
            {
                List<spGet_BTC_USDT_OpenOrdersResult> result = (List<spGet_BTC_USDT_OpenOrdersResult>)(await db.QueryAsync<spGet_BTC_USDT_OpenOrdersResult>("exec spGet_BTC_USDT_OpenOrders"));

                return result;
            }
        }

        public async Task<List<OrderBookModel>> Get_BTC_USDT_OrderBookAsync(int count = 15)
        {
            using (IDbConnection db = new SqlConnection(_configuration.GetConnectionString("ExchangeConnection")))
            {
                try
                {
                    var res = (await db.QueryAsync<OrderBookModel>("exec spGet_BTC_USDT_SortedOrderBook"))
                        .ToList().Take(count);

                    return res.ToList();
                }
                catch { return null; }
        }
        }

        public async Task<OpenOrder> Add_BTC_USDT_OrderAsync(OpenOrder order)
        {
            using (IDbConnection db = new SqlConnection(_configuration.GetConnectionString("ExchangeConnection")))
            {
                try
                {
                    var p = new DynamicParameters();
                    p.Add("isBuy", order.IsBuy);
                    p.Add("price", order.Price);
                    p.Add("amount", order.Amount);
                    p.Add("userid", order.CreateUserId);
                    p.Add("new_identity", dbType: DbType.Int32, direction: ParameterDirection.Output);

                    var res = await db.QueryAsync<long>("spAdd_BTC_USDT_Order", p, commandType: CommandType.StoredProcedure);

                    order.OpenOrderId = res.FirstOrDefault();

                    return order;
                }
                catch { return null; }
            }
        }
    }
}
