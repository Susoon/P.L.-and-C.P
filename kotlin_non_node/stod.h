#include <stdio.h>

double stod(char * str)
	{
		int max, i = 0, sign = 1;
		double ret = 0, exp = 1;

		if(str[0] == '-')
		{
			sign = -1;
			i++;
		}
		else if(str[0] == '+')
		{
			sign = 1;
			i++;
		}

		max = i;
		while((str[max] >= '0' && str[max] <= '9') || (str[max] == '.')) { max++; }
		while(i < max && str[i] != '.')
		{
			ret *= 10;
			ret += (str[i] - '0');
			i++;
		}

		ret *= sign;

		if(str[i] == '\0')
			return ret;
		
		i++;
		while(i < max)
		{
			ret *= 10;
			ret += (str[i] - '0');
			exp *= 0.1;
			i++;
		}
		ret *= exp;

		return ret;
	}


