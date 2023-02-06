-- Nguyễn Bảo Trọng
-- MSSV: 21880154
-- Email: nbtrong73@gmail.com

-- BT6.1. tg_delMuon
-- Thao tác xóa 1 dòng vào quan hệ Muon. Cập nhật tình trạng của cuốn sách là 'Y'
CREATE TRIGGER tg_delMuon 
ON Muon
FOR DELETE
AS BEGIN
	DECLARE @isbn int, @ma_cuonsach int
	SELECT @isbn = isbn, @ma_cuonsach = Ma_CuonSach
	FROM DELETED
	UPDATE CuonSach
	SET TinhTrang ='Y' 
	WHERE isbn = @isbn AND Ma_CuonSach = @ma_cuonsach
END

-- BT6.2. tg_insMuon:
-- Thao tác thêm 1 dòng vào quan hệ Muon. Cập nhật tình trạng của cuốn sách là 'N'
CREATE TRIGGER tg_insMuon 
ON Muon
FOR INSERT
AS BEGIN
	DECLARE @isbn int, @ma_cuonsach int
	SELECT @isbn = isbn, @ma_cuonsach = Ma_CuonSach
	FROM INSERTED
	UPDATE CuonSach
	SET TinhTrang ='N' 
	WHERE isbn = @isbn AND Ma_CuonSach = @ma_cuonsach
END

-- BT6.3. tg_updCuonSach:
-- Khi thuộc tính tình trạng trên bảng cuốn sách được cập nhật thì trạng thái của đầu sách cũng được cập nhật theo
CREATE TRIGGER tg_updCuonSach
ON CuonSach
FOR UPDATE
AS BEGIN
	DECLARE @isbn int, @ma_cuonsach int
	SELECT @isbn = isbn, @ma_cuonsach = Ma_CuonSach
	FROM INSERTED
	IF( (SELECT COUNT(*)  FROM CuonSach WHERE isbn = @isbn AND TinhTrang ='Y') > 0 )
		BEGIN
			UPDATE DauSach
			SET TrangThai = 'Y'
			WHERE isbn = @isbn
		END
	ELSE 
		BEGIN
			UPDATE DauSach
			SET TrangThai = 'N'
			WHERE isbn = @isbn
		END
END