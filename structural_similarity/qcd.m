function qcd = qcd(quant)

    qq = quantile(quant, [.25 .75]);
    qcd = (qq(2) - qq(1)) ./ (qq(2) + qq(1));

end