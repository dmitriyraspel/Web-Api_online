﻿using Dapper;

using Microsoft.Extensions.Configuration;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

using Web_Api.online.Models;

namespace Web_Api.online.Data.Repositories
{
    public class UserRepository
    {
        private readonly IDbConnection _dbWebApi;
        private readonly IDbConnection _dbExchange;
        public UserRepository(IConfiguration configuration)
        {
            _dbWebApi = new SqlConnection(configuration.GetConnectionString("DefaultConnection"));
            _dbExchange = new SqlConnection(configuration.GetConnectionString("ExchangeConnection"));
        }
        public async Task<List<spGetUsers_PagedSettings>> GetPagedUsers(int page, int pageSize)
        {
            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("page", page);
                parameters.Add("pageSize", pageSize);

                return (await _dbWebApi.QueryAsync<spGetUsers_PagedSettings>(
                        "GetUsers_Paged",
                        parameters,
                        commandType: CommandType.StoredProcedure)).ToList();
            }
            catch (Exception exc)
            {
                return null;
            }
        }

        public async Task<List<spGetUsers_PagedSettings>> FindPagedUsersByUsername(string userName, int page, int pageSize)
        {
            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("userName", userName);
                parameters.Add("page", page);
                parameters.Add("pageSize", pageSize);

                return (await _dbWebApi.QueryAsync<spGetUsers_PagedSettings>(
                        "FindUsersByUsername_Paged",
                        parameters,
                        commandType: CommandType.StoredProcedure)).AsList();
            }
            catch (Exception exc)
            {
                return null;
            }
        }

        public async Task<string> FindUserIdForSendPageAsync(string searchText)
        {
            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("searchText", searchText);

                var useId = await _dbWebApi.QueryFirstOrDefaultAsync<string>(
                        "FindUserIdForSendPageWebApi",
                        parameters,
                        commandType: CommandType.StoredProcedure);

                if(useId == null)
                {
                    useId = await _dbExchange.QueryFirstOrDefaultAsync<string>(
                        "FindUserIdForSendPageExchange",
                        parameters,
                        commandType: CommandType.StoredProcedure);
                }
                return useId;
            }
            catch (Exception exc)
            {
                return null;
            }
        }

        public async Task<int> GetCountOfUsers()
        {
            try
            {
                return await _dbWebApi.QueryFirstAsync<int>(
                    "GetCountOfUsers",
                    commandType: CommandType.StoredProcedure);
            }
            catch (Exception exc)
            {
                return 0;
            }
        }
    }
}
