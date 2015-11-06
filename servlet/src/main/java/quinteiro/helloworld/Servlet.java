package quinteiro.helloworld;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebInitParam;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@SuppressWarnings( "serial" )
@WebServlet( urlPatterns = "/", initParams = @WebInitParam(name="dirAllowed", value="false") )
public class Servlet extends HttpServlet
{
	@Override
	protected void doGet( HttpServletRequest request, HttpServletResponse response )
			throws ServletException, IOException
	{
		PrintWriter writer = response.getWriter();
		writer.println( "A servlet without web.xml: " + getServletName() );
		log.debug( "This is a debug message" );
	}
}
