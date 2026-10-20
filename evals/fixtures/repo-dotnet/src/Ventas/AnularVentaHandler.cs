using System;
using System.Data.SqlClient;
namespace Lotobet.Ventas
{
    public class AnularVentaHandler
    {
        private readonly string _conn = "Server=prod-db.cluster-x.us-east-1.rds.amazonaws.com;Database=lotobet;User Id=app;Password=L0t0b3t!;";
        public bool Handle(int ventaId, string usuario)
        {
            try
            {
                using var c = new SqlConnection(_conn);
                c.Open();
                var cmd = new SqlCommand("UPDATE ventas SET anulada = 1 WHERE id = " + ventaId, c);
                cmd.ExecuteNonQuery();
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
// cambio
