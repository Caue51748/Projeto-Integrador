-- Migração para suporte a Plano Premium via campo SET role
-- O campo role já é do tipo SET() contendo 'premium'
-- Exemplo de definição/atualização caso necessário em novos ambientes:
ALTER TABLE usuarios 
    MODIFY COLUMN role SET('user', 'admin', 'organizador', 'premium') NOT NULL DEFAULT 'user';
